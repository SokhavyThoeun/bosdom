import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/price_display.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/mock_images.dart';
import '../../../shared/widgets/checkout_progress_stepper.dart';
import '../../cart/providers/cart_provider.dart';
import '../../co_buying/providers/co_buy_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/services/order_service.dart';
import '../services/payway_service.dart';
import '../widgets/card_checkout_sheet.dart';

enum _PaymentMethod { khqr, card }

/// A purchased line item, summarized for the payment/confirmation flow.
class OrderLineSummary {
  const OrderLineSummary({
    required this.icon,
    required this.imageUrl,
    required this.name,
    required this.qtyLabel,
    required this.total,
    required this.seller,
    this.sellerLogoOverride,
    this.listingId,
    this.quantity = 1,
  });

  final IconData icon;
  final String imageUrl;
  final String name;
  final String qtyLabel;
  final double total;
  final String seller;

  /// Real shop logo URL for this line's seller. `null` for demo/co-buy
  /// lines, which fall back to [sellerLogoUrl]'s generated mock logo.
  final String? sellerLogoOverride;

  /// Real backend listing id, when this line is a real product — `null`
  /// for demo/co-buy lines that have no backend counterpart to order.
  final String? listingId;
  final int quantity;

  /// The seller's real shop logo when available, else a generated mock logo.
  String get sellerLogoUrl => sellerLogoOverride ?? mockStoreLogoUrl(seller);
}

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({
    super.key,
    required this.amount,
    this.shippingFee = 0,
    this.itemCount = 3,
    this.items = const [],
    this.shippingName = '',
    this.shippingAddress = '',
    this.shippingPhone = '',
    this.coBuyPoolId,
  });

  final double amount;

  /// Part of [amount] that's shipping — the backend adds it to the items
  /// when working out what PayWay should charge.
  final double shippingFee;
  final int itemCount;
  final List<OrderLineSummary> items;
  final String shippingName;
  final String shippingAddress;
  final String shippingPhone;

  /// When set, this payment settles a pending co-buy join instead of the
  /// items above — [_payNow] calls the co-buy pay-join endpoint rather than
  /// creating regular orders.
  final String? coBuyPoolId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  _PaymentMethod _selectedMethod = _PaymentMethod.khqr;
  bool _isPaying = false;
  bool _orderConfirmed = false;

  /// Backend orders created for this checkout, still awaiting payment —
  /// reused when the buyer closes the QR sheet and retries (or switches to
  /// card) so a retry doesn't duplicate them.
  List<String>? _pendingOrderIds;

  /// The most recent KHQR transaction opened from this screen.
  String? _khqrTranId;

  Future<void> _onPayNowPressed() async {
    switch (_selectedMethod) {
      case _PaymentMethod.khqr:
        await _payWithKhqr();
      case _PaymentMethod.card:
        await _payWithCard();
    }
  }

  /// Opens a real ABA PayWay card payment: PayWay's hosted card page in a
  /// WebView, until the backend sees PayWay approve it.
  Future<void> _payWithCard() async {
    setState(() => _isPaying = true);
    final CardCheckout checkout;
    try {
      final coBuyPoolId = widget.coBuyPoolId;
      if (coBuyPoolId != null) {
        checkout = await PaywayService.startCard(
          coBuyPoolId: coBuyPoolId,
          shippingFee: widget.shippingFee,
        );
      } else {
        checkout = await PaywayService.startCard(
          orderIds: await _orderIdsToPay(),
          shippingFee: widget.shippingFee,
        );
      }
    } catch (e) {
      _showPaymentError(e);
      return;
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
    if (!mounted) return;

    var paid =
        await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          enableDrag: false,
          backgroundColor: Colors.transparent,
          builder: (context) => CardCheckoutSheet(checkout: checkout),
        ) ??
        false;
    if (!paid) paid = await _paidAfterAll(checkout.tranId);
    if (paid && mounted) await _showOrderConfirmed();
  }

  void _showPaymentError(Object error) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.paymentFailedSnackbar('$error'))),
    );
  }

  /// A payment sheet closed without seeing the payment land — it may still
  /// have gone through in the last few seconds, so ask once more.
  Future<bool> _paidAfterAll(String tranId) async {
    try {
      return await PaywayService.status(tranId) == PaywayPaymentStatus.paid;
    } catch (_) {
      return false;
    }
  }

  /// Opens a real ABA PayWay KHQR payment and shows its QR until the backend
  /// sees PayWay approve it.
  Future<void> _payWithKhqr() async {
    setState(() => _isPaying = true);
    final KhqrPayment payment;
    try {
      payment = await _startKhqr();
    } catch (e) {
      _showPaymentError(e);
      return;
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
    if (!mounted) return;

    var paid = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          _KhqrPaymentSheet(initialPayment: payment, onRefresh: _startKhqr),
    );

    final tranId = _khqrTranId;
    if (paid != true && tranId != null) paid = await _paidAfterAll(tranId);
    if (paid == true && mounted) await _showOrderConfirmed();
  }

  Future<KhqrPayment> _startKhqr() async {
    final coBuyPoolId = widget.coBuyPoolId;
    final KhqrPayment payment;
    if (coBuyPoolId != null) {
      payment = await PaywayService.startKhqr(
        coBuyPoolId: coBuyPoolId,
        shippingFee: widget.shippingFee,
      );
    } else {
      payment = await PaywayService.startKhqr(
        orderIds: await _orderIdsToPay(),
        shippingFee: widget.shippingFee,
      );
    }
    _khqrTranId = payment.tranId;
    return payment;
  }

  /// This checkout's backend orders, created on the first payment attempt
  /// and reused by later ones.
  Future<List<String>> _orderIdsToPay() async {
    final noPayableItems = AppLocalizations.of(context).paymentNoPayableItems;
    final orderIds = _pendingOrderIds ??= await _createOrders();
    if (orderIds.isEmpty) throw PaymentException(noPayableItems);
    return orderIds;
  }

  /// One backend `Order` per line that carries a real listing id — demo
  /// lines have no backend counterpart to order, so they're skipped.
  Future<List<String>> _createOrders() async {
    final ids = <String>[];
    for (final line in widget.items) {
      final listingId = line.listingId;
      if (listingId == null) continue;
      final order = await OrderService.createOrder(
        listingId: listingId,
        quantity: line.quantity,
        shippingName: widget.shippingName,
        shippingAddress: widget.shippingAddress,
        shippingPhone: widget.shippingPhone,
      );
      ids.add(order.id);
    }
    return ids;
  }

  /// Shows the confirming → confirmed flow once PayWay has approved the
  /// payment and the backend has moved it into escrow.
  Future<void> _showOrderConfirmed() async {
    setState(() => _isPaying = true);

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    unawaited(
      rootNavigator.push(
        PageRouteBuilder<void>(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const _ConfirmingOrderScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    );

    try {
      final minDelay = Future.delayed(const Duration(milliseconds: 1900));

      final coBuyPoolId = widget.coBuyPoolId;
      final paidListingIds = <String>{};
      if (coBuyPoolId != null) {
        ref.invalidate(coBuyProvider);
      } else {
        paidListingIds.addAll(widget.items.map((l) => l.listingId).nonNulls);
      }

      await minDelay;

      if (!mounted) return;
      setState(() => _orderConfirmed = true);
      rootNavigator.pop();

      if (paidListingIds.isNotEmpty) {
        ref.invalidate(ordersProvider);
        ref.read(cartProvider.notifier).removeByListingIds(paidListingIds);
      }

      final viewOrder = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.45),
        transitionDuration: const Duration(milliseconds: 480),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _OrderConfirmedDialog(
              amount: widget.amount,
              itemCount: widget.itemCount,
              items: widget.items,
            ),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
            reverseCurve: Curves.easeIn,
          );
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.28),
                end: Offset.zero,
              ).animate(curved),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.82, end: 1).animate(curved),
                child: child,
              ),
            ),
          );
        },
      );
      if (!mounted) return;
      if (viewOrder == true) {
        // Clear the checkout/payment stack back to the marketplace first,
        // then push the relevant destination on top — so its back button
        // returns to the marketplace instead of back into payment/checkout.
        context.go('/marketplace');
        if (coBuyPoolId != null) {
          context.pushNamed('coBuyDetail', pathParameters: {'id': coBuyPoolId});
        } else {
          // This mock flow doesn't create a real backend order (see the note
          // above), so there's no specific order id to jump straight to a
          // detail view of.
          context.pushNamed('orders');
        }
      } else {
        context.go('/marketplace');
      }
    } catch (e) {
      rootNavigator.pop();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.paymentFailedSnackbar('$e'))));
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          _PaymentHeader(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: CheckoutProgressStepper(
                      currentStep: CheckoutStep.payment,
                      completed: _orderConfirmed,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.checkoutOrderItemsLabel,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                l10n.checkoutItemsCount(widget.items.length),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _OrderItemsSection(
                            items: widget.items,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.paymentSelectMethodLabel,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Rows and logos follow PayWay's eCommerce checkout
                          // guideline (aba_resource/method*.svg).
                          _PaymentMethodTile(
                            iconAsset: 'assets/payway/aba_khqr_tile.svg',
                            title: l10n.paymentKhqrMethodTitle,
                            subtitle: Text(
                              l10n.paymentKhqrSubtitle,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            selected: _selectedMethod == _PaymentMethod.khqr,
                            onTap: () => setState(
                              () => _selectedMethod = _PaymentMethod.khqr,
                            ),
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                          const SizedBox(height: 12),
                          _PaymentMethodTile(
                            iconAsset: 'assets/payway/card_tile.svg',
                            title: l10n.paymentCardMethodTitle,
                            subtitle: const _PaymentLogos(
                              assets: _kCardLogos,
                              height: 14,
                            ),
                            selected: _selectedMethod == _PaymentMethod.card,
                            onTap: () => setState(
                              () => _selectedMethod = _PaymentMethod.card,
                            ),
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                l10n.paymentWeAcceptLabel,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: _PaymentLogos(
                                  assets: _kAcceptedLogos,
                                  height: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _AmountToPayCard(
                            amount: widget.amount,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      20 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isPaying ? null : _onPayNowPressed,
                        child: _isPaying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(l10n.paymentPayNowButton),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sized to fit a back-row + centered title, shorter than the two-row
// home/search header since there's no search bar to fit.
const _kHeaderContentHeight = 68.0;

class _PaymentHeader extends StatelessWidget {
  const _PaymentHeader({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 10,
          24,
          14,
        ),
        child: SizedBox(
          height: _kHeaderContentHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Icon(
                      Icons.arrow_back,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Text(
                l10n.paymentScreenTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _kCardLogos = [
  'assets/payway/visa.svg',
  'assets/payway/mastercard.svg',
  'assets/payway/unionpay.svg',
  'assets/payway/jcb.svg',
];

/// PayWay's "We accept" strip: every scheme its checkout takes.
const _kAcceptedLogos = [
  'assets/payway/aba.svg',
  'assets/payway/khqr.svg',
  ..._kCardLogos,
];

class _PaymentLogos extends StatelessWidget {
  const _PaymentLogos({required this.assets, required this.height});

  final List<String> assets;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: height * 0.45,
      runSpacing: 6,
      children: [
        for (final asset in assets) SvgPicture.asset(asset, height: height),
      ],
    );
  }
}

/// One payment option, laid out like PayWay's guideline rows: brand tile,
/// title, then a caption or the accepted card logos.
class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final String iconAsset;
  final String title;
  final Widget subtitle;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryContainer : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              SvgPicture.asset(iconAsset, width: 44, height: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    subtitle,
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmountToPayCard extends ConsumerWidget {
  const _AmountToPayCard({
    required this.amount,
    required this.colorScheme,
    required this.textTheme,
  });

  final double amount;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          Text(
            l10n.paymentAmountToPayLabel,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          PriceDisplay(
            amount,
            crossAxisAlignment: CrossAxisAlignment.center,
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen "confirming order" loader shown while payment is being
/// processed, mirroring the delayed-spinner pattern used by booking apps:
/// a ring spinner circles the brand mark while the request is in flight.
class _ConfirmingOrderScreen extends StatefulWidget {
  const _ConfirmingOrderScreen();

  @override
  State<_ConfirmingOrderScreen> createState() => _ConfirmingOrderScreenState();
}

class _ConfirmingOrderScreenState extends State<_ConfirmingOrderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final ringFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );
    final ringScale = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    final textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1, curve: Curves.easeOut),
    );
    final textRise = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(textFade);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: ringFade,
              child: ScaleTransition(
                scale: ringScale,
                child: SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.blushSurface,
                            width: 4,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.brandCrimson,
                          ),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x22000000),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Image.asset('assets/images/bosdom-logo-red.png'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: textFade,
              child: SlideTransition(
                position: textRise,
                child: Text(
                  l10n.paymentConfirmingTitle,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warmBlack,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: textFade,
              child: SlideTransition(
                position: textRise,
                child: Text(
                  l10n.paymentConfirmingSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.warmTaupe,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact "flying in" confirmation popup shown once the order clears —
/// a small centered card (not a full sheet) summarizing what was bought.
class _OrderConfirmedDialog extends ConsumerWidget {
  const _OrderConfirmedDialog({
    required this.amount,
    required this.itemCount,
    required this.items,
  });

  final double amount;
  final int itemCount;
  final List<OrderLineSummary> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final lines = items;
    final groups = <String, List<OrderLineSummary>>{};
    for (final line in lines) {
      groups.putIfAbsent(line.seller, () => []).add(line);
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.tertiary.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: colorScheme.tertiary,
                    size: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.paymentConfirmedTitle,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.paymentConfirmedSubtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  if (lines.isNotEmpty)
                    for (var flyIndex = 0, g = 0; g < groups.length; g++) ...[
                      _FlyInItem(
                        index: flyIndex++,
                        child: Padding(
                          padding: EdgeInsets.only(top: g == 0 ? 0 : 8),
                          child: _SellerHeaderRow(
                            seller: groups.keys.elementAt(g),
                            logoUrl: groups.values
                                .elementAt(g)
                                .first
                                .sellerLogoUrl,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                        ),
                      ),
                      for (final line in groups.values.elementAt(g)) ...[
                        _FlyInItem(
                          index: flyIndex++,
                          child: _OrderLineRow(
                            line: line,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                        ),
                        if (line != groups.values.elementAt(g).last)
                          Divider(color: colorScheme.outline, height: 1),
                      ],
                      if (g != groups.length - 1)
                        Divider(color: colorScheme.outline, height: 1),
                    ]
                  else
                    _FlyInItem(
                      index: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Text(
                              l10n.paymentWholesaleItemsFallbackLabel,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              l10n.paymentItemsPurchasedLabel(itemCount),
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _FlyInItem(
              index: lines.length.clamp(0, 4) + 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Text(
                      l10n.paymentTotalPaidLabel,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    PriceDisplay(
                      amount,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.pop(true),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(l10n.paymentViewOrdersButton),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: TextButton(
                onPressed: () => context.pop(false),
                child: Text(
                  l10n.paymentContinueShoppingButton,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Product photos + line totals for the items being paid for, grouped by
/// seller — mirrors checkout_screen's `_OrderItemsCard` so the product
/// pictures stay visible through every step (cart, checkout, payment,
/// confirmation) instead of dropping out once you reach payment.
class _OrderItemsSection extends StatelessWidget {
  const _OrderItemsSection({
    required this.items,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<OrderLineSummary> items;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<OrderLineSummary>>{};
    for (final line in items) {
      groups.putIfAbsent(line.seller, () => []).add(line);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in groups.entries) ...[
            _SellerHeaderRow(
              seller: entry.key,
              logoUrl: entry.value.first.sellerLogoUrl,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            for (final line in entry.value) ...[
              Divider(color: colorScheme.outlineVariant, height: 20),
              _PaymentOrderLineRow(
                line: line,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
            if (entry.key != groups.keys.last) const Divider(height: 20),
          ],
        ],
      ),
    );
  }
}

/// A single order line on the main payment screen's order-items card —
/// same image size/spacing as checkout_screen's `_SellerGroupCard` row so
/// the item photo stays the same prominence one step later, rather than
/// shrinking down to the compact size used by the "Order Confirmed" popup.
class _PaymentOrderLineRow extends ConsumerWidget {
  const _PaymentOrderLineRow({
    required this.line,
    required this.colorScheme,
    required this.textTheme,
  });

  final OrderLineSummary line;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.network(
            line.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : Icon(line.icon, color: colorScheme.primary, size: 20),
            errorBuilder: (context, error, stackTrace) =>
                Icon(line.icon, color: colorScheme.primary, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                line.qtyLabel,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatPrice(ref, line.total),
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Store logo + seller name, shown once above each seller's items —
/// mirrors the seller group header on the checkout screen's order-items
/// card so the two screens read as the same order.
class _SellerHeaderRow extends StatelessWidget {
  const _SellerHeaderRow({
    required this.seller,
    required this.logoUrl,
    required this.colorScheme,
    required this.textTheme,
  });

  final String seller;
  final String logoUrl;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 9,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: Image.network(
              logoUrl,
              width: 18,
              height: 18,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Icon(
                      Icons.storefront_outlined,
                      size: 11,
                      color: colorScheme.primary,
                    ),
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.storefront_outlined,
                size: 11,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            seller,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/// A single purchased item row: product photo, name/qty, price.
class _OrderLineRow extends ConsumerWidget {
  const _OrderLineRow({
    required this.line,
    required this.colorScheme,
    required this.textTheme,
  });

  final OrderLineSummary line;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Image.network(
              line.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : Icon(line.icon, color: colorScheme.primary, size: 17),
              errorBuilder: (context, error, stackTrace) =>
                  Icon(line.icon, color: colorScheme.primary, size: 17),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  line.qtyLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatPrice(ref, line.total),
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Staggers each order-summary row in with a short slide + fade so the
/// popup's contents "fly" into place rather than appearing all at once.
class _FlyInItem extends StatefulWidget {
  const _FlyInItem({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_FlyInItem> createState() => _FlyInItemState();
}

class _FlyInItemState extends State<_FlyInItem> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 90 * widget.index + 80), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0.3, 0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// KHQR "scan to pay" bottom sheet for a real ABA PayWay transaction: the
/// QR in PayWay's KHQR presentation ([_KhqrPanel]) with a countdown, an "Open
/// ABA Mobile" shortcut, and a status poll that closes the sheet (with
/// `true`) as soon as the backend sees PayWay approve the payment.
class _KhqrPaymentSheet extends StatefulWidget {
  const _KhqrPaymentSheet({
    required this.initialPayment,
    required this.onRefresh,
  });

  final KhqrPayment initialPayment;

  /// Opens a fresh transaction once this one's QR has expired.
  final Future<KhqrPayment> Function() onRefresh;

  @override
  State<_KhqrPaymentSheet> createState() => _KhqrPaymentSheetState();
}

class _KhqrPaymentSheetState extends State<_KhqrPaymentSheet> {
  static const _pollInterval = Duration(seconds: 3);

  late KhqrPayment _payment;
  late int _secondsLeft;
  Timer? _countdownTimer;
  Timer? _pollTimer;
  Timer? _sandboxTimer;
  bool _polling = false;
  bool _refreshing = false;

  /// Set once PayWay has settled the payment without it going through
  /// (declined, or a co-buy deal that filled up first).
  PaywayPaymentStatus? _failure;
  String? _error;

  @override
  void initState() {
    super.initState();
    _payment = widget.initialPayment;
    _startTimers();
  }

  void _startTimers() {
    _secondsLeft = _secondsUntilExpiry();
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _secondsLeft = _secondsUntilExpiry());
    });
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
    _sandboxTimer?.cancel();
    final approveAfter = _payment.sandboxApproveAfter;
    if (approveAfter != null) {
      _sandboxTimer = Timer(approveAfter, _sandboxApprove);
    }
  }

  int _secondsUntilExpiry() =>
      math.max(0, _payment.expiresAt.difference(DateTime.now()).inSeconds);

  /// Sandbox QR codes can't be paid by a real banking app, so on the
  /// sandbox the backend is told to treat this one as scanned and paid.
  Future<void> _sandboxApprove() async {
    try {
      await PaywayService.sandboxApprove(_payment.tranId);
    } catch (_) {
      // Leave it to the normal poll.
    }
    await _poll();
  }

  Future<void> _poll() async {
    if (_polling) return;
    _polling = true;
    try {
      final status = await PaywayService.status(_payment.tranId);
      if (!mounted) return;
      switch (status) {
        case PaywayPaymentStatus.paid:
          _stopTimers();
          Navigator.of(context).pop(true);
        case PaywayPaymentStatus.failed || PaywayPaymentStatus.refundDue:
          _stopTimers();
          setState(() => _failure = status);
        case PaywayPaymentStatus.expired:
          // Nothing more can land on this QR — stop asking about it.
          _stopTimers();
          setState(() => _secondsLeft = 0);
        case PaywayPaymentStatus.pending:
          // Keep polling, even just past the countdown: a scan in the last
          // seconds can still come through.
          break;
      }
    } catch (_) {
      // A dropped poll is fine; the next tick tries again.
    } finally {
      _polling = false;
    }
  }

  Future<void> _refreshCode() async {
    setState(() {
      _refreshing = true;
      _error = null;
    });
    try {
      final next = await widget.onRefresh();
      if (!mounted) return;
      setState(() {
        _payment = next;
        _failure = null;
      });
      _startTimers();
    } catch (e) {
      // The old QR may have been paid after all (the backend refuses to
      // open another payment then) — check before showing the error.
      await _poll();
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _openAbaMobile() async {
    final l10n = AppLocalizations.of(context);
    var opened = false;
    final uri = Uri.tryParse(_payment.deeplink);
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened && mounted) {
      setState(() => _error = l10n.paymentKhqrAbaNotInstalled);
    }
  }

  void _stopTimers() {
    _countdownTimer?.cancel();
    _pollTimer?.cancel();
    _sandboxTimer?.cancel();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final failure = _failure;
    final expired = _secondsLeft == 0 || failure != null;
    final error = _error;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.paymentKhqrSheetTitle,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.outline),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _KhqrPanel(
                          amountUsd: _payment.amount,
                          qrData: _payment.qrString,
                          dimmed: expired,
                        ),
                        const SizedBox(height: 16),
                        if (failure == PaywayPaymentStatus.refundDue)
                          Text(
                            l10n.paymentKhqrRefundDueLabel,
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (expired) ...[
                          Text(
                            failure == PaywayPaymentStatus.failed
                                ? l10n.paymentKhqrFailedLabel
                                : l10n.paymentKhqrExpiredLabel,
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _refreshing ? null : _refreshCode,
                            icon: _refreshing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh, size: 18),
                            label: Text(l10n.paymentKhqrRefreshButton),
                          ),
                        ] else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.paymentKhqrExpiresLabel(_formattedTime),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        if (error != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            error,
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: expired || _payment.deeplink.isEmpty
                      ? null
                      : _openAbaMobile,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l10n.paymentKhqrOpenAbaButton),
                ),
                if (!expired) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.paymentKhqrWaitingLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// PayWay's KHQR presentation, from `aba_resource/paywayqr.svg` and the
/// placement rules in `aba_resource/qr_guideline.png`: the ABA PAY logo, the
/// KHQR card and the scan caption on a grey panel with the guideline's
/// protected white outline (6px, 18px corners) and 24px safe space. Laid out
/// 1:1 on the design's 196px-wide grid, which keeps the QR at the
/// guideline's 144px maximum. The colours are PayWay's brand spec, not the
/// app theme's.
class _KhqrPanel extends StatelessWidget {
  const _KhqrPanel({
    required this.amountUsd,
    required this.qrData,
    required this.dimmed,
  });

  final double amountUsd;
  final String qrData;
  final bool dimmed;

  static const _panelColor = Color(0xFFE8E9EC);
  static const _captionColor = Color(0xFF878787);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 6),
      ),
      child: SizedBox(
        width: _KhqrCard.width,
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/payway/aba_pay.svg',
              width: _KhqrCard.width,
            ),
            const SizedBox(height: 32),
            AnimatedOpacity(
              opacity: dimmed ? 0.35 : 1,
              duration: const Duration(milliseconds: 250),
              child: _KhqrCard(amountUsd: amountUsd, qrData: qrData),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.paymentKhqrInstructions,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                height: 1.35,
                color: _captionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The KHQR card itself (paywayqr.svg's 196x301 card): red KHQR header with
/// its folded corner, merchant and amount, a dashed divider, then the QR with
/// the Bakong badge — which PayWay shows whatever the currency.
class _KhqrCard extends StatelessWidget {
  const _KhqrCard({required this.amountUsd, required this.qrData});

  final double amountUsd;
  final String qrData;

  static const width = 196.0;
  static const _height = 301.0;
  static const _qrSize = 144.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: _height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [BoxShadow(color: Color(0x29000000), blurRadius: 11)],
      ),
      child: Stack(
        children: [
          SvgPicture.asset(
            'assets/payway/khqr_card_header.svg',
            width: width,
            height: 54,
          ),
          Positioned(
            left: 26.7,
            top: 52,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BosDom Marketplace',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.2,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4.6),
                Text(
                  '\$ ${NumberFormat('#,##0.00', 'en_US').format(amountUsd)}',
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 105,
            child: CustomPaint(
              size: Size(width, 1),
              painter: _DashedLinePainter(),
            ),
          ),
          Positioned(
            left: (width - _qrSize) / 2,
            top: 131,
            width: _qrSize,
            height: _qrSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                QrImageView(
                  data: qrData,
                  size: _qrSize,
                  padding: EdgeInsets.zero,
                  // High error correction so the centre badge can cover part
                  // of the code and it still scans.
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
                SvgPicture.asset(
                  'assets/payway/bakong_badge.svg',
                  width: 41,
                  height: 41,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// paywayqr.svg's divider: black at 50%, 0.5px, 4.14px dashes and gaps.
class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  static const _dash = 4.14;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..strokeWidth = 0.5175;
    for (var x = 0.0; x < size.width; x += _dash * 2) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + _dash, size.width), 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
