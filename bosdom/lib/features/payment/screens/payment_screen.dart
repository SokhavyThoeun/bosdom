import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/providers/currency_provider.dart';
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

enum _PaymentMethod { card, khqr }

/// Mock riel/dollar rate used only to render a KHQR amount — this app has
/// no real Bakong integration, so there's no live FX feed to call.
const _kMockKhrPerUsd = 4100.0;

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
    this.itemCount = 3,
    this.items = const [],
    this.shippingName = '',
    this.shippingAddress = '',
    this.shippingPhone = '',
    this.coBuyPoolId,
  });

  final double amount;
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
  _PaymentMethod _selectedMethod = _PaymentMethod.card;
  bool _isPaying = false;
  bool _orderConfirmed = false;

  Future<void> _onPayNowPressed() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _selectedMethod == _PaymentMethod.khqr
          ? _KhqrPaymentSheet(
              amount: widget.amount,
              currency: ref.read(currencyProvider),
              showBoth: ref.read(showBothCurrenciesProvider),
            )
          : _CardDetailsSheet(amount: widget.amount),
    );

    if (confirmed == true) {
      await _payNow();
    }
  }

  Future<void> _payNow() async {
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
        // Co-buy join: the pending participation already exists (created at
        // "Join Deal"), this just moves it into held escrow.
        await ref
            .read(coBuyProvider.notifier)
            .payJoin(coBuyPoolId, _selectedMethod.name);
      } else {
        // Real backend orders (15.1/15.2): one `Order` per line that carries
        // a real listing id — demo lines have no backend counterpart to
        // order, so they're skipped here and only reflected in this local
        // confirmation UI.
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
          await OrderService.payOrder(order.id, _selectedMethod.name);
          paidListingIds.add(listingId);
        }
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
                          _PaymentMethodTile(
                            imageAsset: 'assets/images/visa-mastercard.webp',
                            imagePadding: 6,
                            title: l10n.paymentCardMethodTitle,
                            subtitle: l10n.paymentMethodSubtitleVisaMastercard,
                            selected: _selectedMethod == _PaymentMethod.card,
                            onTap: () => setState(
                              () => _selectedMethod = _PaymentMethod.card,
                            ),
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                          const SizedBox(height: 12),
                          _PaymentMethodTile(
                            imageAsset: 'assets/images/bakong-logo.png',
                            title: l10n.paymentKhqrMethodTitle,
                            subtitle: l10n.paymentKhqrSubtitle,
                            selected: _selectedMethod == _PaymentMethod.khqr,
                            onTap: () => setState(
                              () => _selectedMethod = _PaymentMethod.khqr,
                            ),
                            colorScheme: colorScheme,
                            textTheme: textTheme,
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

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.imageAsset,
    this.imagePadding = 0,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final String imageAsset;
  final double imagePadding;
  final String title;
  final String subtitle;
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
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: EdgeInsets.all(imagePadding),
                  child: Image.asset(imageAsset, fit: BoxFit.contain),
                ),
              ),
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
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
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

class _CardDetailsSheet extends ConsumerStatefulWidget {
  const _CardDetailsSheet({required this.amount});

  final double amount;

  @override
  ConsumerState<_CardDetailsSheet> createState() => _CardDetailsSheetState();
}

class _CardDetailsSheetState extends ConsumerState<_CardDetailsSheet> {
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cvvFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Redraws the live card preview as the buyer types.
    _cardNumberController.addListener(_refreshPreview);
    _cardHolderController.addListener(_refreshPreview);
    _expiryController.addListener(_refreshPreview);
    _cvvFocusNode.addListener(_refreshPreview);
  }

  void _refreshPreview() => setState(() {});

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cvvFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final formattedAmount = formatPrice(ref, widget.amount);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
                        l10n.paymentPayAmountLabel(formattedAmount),
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
                const SizedBox(height: 6),
                Text(
                  l10n.paymentCardDetailsSubtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _VisaCardPreview(
                  cardNumber: _cardNumberController.text,
                  cardHolder: _cardHolderController.text,
                  expiry: _expiryController.text,
                  cvv: _cvvController.text,
                  showBack: _cvvFocusNode.hasFocus,
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.paymentCardNumberLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: '0000 0000 0000 0000',
                    prefixIcon: Icon(
                      Icons.credit_card,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.paymentCardHolderLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cardHolderController,
                  textCapitalization: TextCapitalization.characters,
                  keyboardType: TextInputType.name,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z '-]")),
                    LengthLimitingTextInputFormatter(26),
                    _UpperCaseTextFormatter(),
                  ],
                  decoration: InputDecoration(
                    hintText: l10n.paymentCardHolderNameHint,
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.paymentExpiryDateLabel,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _expiryController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _ExpiryDateFormatter(),
                            ],
                            decoration: InputDecoration(
                              hintText: 'MM/YY',
                              prefixIcon: Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.paymentCvvLabel,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cvvController,
                            focusNode: _cvvFocusNode,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            obscuringCharacter: '•',
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: InputDecoration(
                              hintText: '***',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                size: 20,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.paymentSecureEncryptionNote,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(l10n.paymentPayAmountLabel(formattedAmount)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Uppercases text as the buyer types, matching how a name is embossed on
/// a real card.
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// A live-updating "credit card" visual (gradient, embossed digits, EMV
/// chip, VISA wordmark) mirroring what the buyer is typing into
/// [_CardDetailsSheet], flipping to a back face with the CVV while that
/// field is focused — there is no real card network/Stripe behind this,
/// purely a UI mock.
class _VisaCardPreview extends StatelessWidget {
  const _VisaCardPreview({
    required this.cardNumber,
    required this.cardHolder,
    required this.expiry,
    required this.cvv,
    required this.showBack,
  });

  final String cardNumber;
  final String cardHolder;
  final String expiry;
  final String cvv;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: showBack ? 1 : 0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        final isBackHalf = value > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(value * math.pi),
          child: isBackHalf
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _VisaCardBack(cvv: cvv),
                )
              : _VisaCardFront(
                  cardNumber: cardNumber,
                  cardHolder: cardHolder,
                  expiry: expiry,
                ),
        );
      },
    );
  }
}

class _VisaCardFront extends StatelessWidget {
  const _VisaCardFront({
    required this.cardNumber,
    required this.cardHolder,
    required this.expiry,
  });

  final String cardNumber;
  final String cardHolder;
  final String expiry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final digits = cardNumber.replaceAll(' ', '');
    final groups = List.generate(4, (i) {
      final start = i * 4;
      if (start >= digits.length) return '••••';
      final end = (start + 4).clamp(0, digits.length);
      return digits.substring(start, end).padRight(4, '•');
    });
    final expiryDisplay = expiry.isEmpty ? 'MM/YY' : expiry;
    final holderDisplay = cardHolder.trim().isEmpty
        ? l10n.paymentCardHolderPlaceholder
        : cardHolder.trim();
    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.65),
      fontSize: 9,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
    );
    const valueStyle = TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    return _CardFace(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _EmvChip(),
              const SizedBox(width: 10),
              Transform.rotate(
                angle: math.pi / 2,
                child: Icon(
                  Icons.wifi_rounded,
                  color: Colors.white.withValues(alpha: 0.85),
                  size: 20,
                ),
              ),
              const Spacer(),
              const _VisaWordmark(),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            groups.join('  '),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              shadows: [Shadow(color: Color(0x40000000), offset: Offset(0, 1))],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.paymentCardHolderLabel, style: labelStyle),
                    const SizedBox(height: 4),
                    Text(
                      holderDisplay,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: valueStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.paymentCardValidThruLabel, style: labelStyle),
                  const SizedBox(height: 4),
                  Text(expiryDisplay, style: valueStyle),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisaCardBack extends StatelessWidget {
  const _VisaCardBack({required this.cvv});

  final String cvv;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cvvDisplay = cvv.isEmpty ? '•••' : cvv;

    return _CardFace(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 22),
          Container(height: 40, color: Colors.black.withValues(alpha: 0.75)),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 30,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      cvvDisplay,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              l10n.paymentCvvLabel,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: _VisaWordmark(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared front/back card shell: gradient, rounded corners, shadow, and a
/// faint highlight so the card reads as glossy rather than flat.
class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.brandCrimson, AppColors.deepBurgundy],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

class _EmvChip extends StatelessWidget {
  const _EmvChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 28,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF6E7B4), Color(0xFFC9A24B)],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: CustomPaint(painter: _EmvChipPainter()),
    );
  }
}

class _EmvChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x33000000)
      ..strokeWidth = 1;
    final midY1 = size.height * 0.34;
    final midY2 = size.height * 0.66;
    final leftX = size.width * 0.28;
    final rightX = size.width * 0.72;

    canvas.drawLine(Offset(0, midY1), Offset(size.width, midY1), paint);
    canvas.drawLine(Offset(0, midY2), Offset(size.width, midY2), paint);
    canvas.drawLine(
      Offset(size.width / 2, midY1),
      Offset(size.width / 2, midY2),
      paint,
    );
    canvas.drawLine(Offset(leftX, 0), Offset(leftX, midY1), paint);
    canvas.drawLine(Offset(rightX, 0), Offset(rightX, midY1), paint);
    canvas.drawLine(Offset(leftX, midY2), Offset(leftX, size.height), paint);
    canvas.drawLine(Offset(rightX, midY2), Offset(rightX, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _EmvChipPainter oldDelegate) => false;
}

class _VisaWordmark extends StatelessWidget {
  const _VisaWordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'VISA',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
        letterSpacing: 1,
      ),
    );
  }
}

/// KHQR/Bakong "scan to pay" mock — a bottom sheet showing a generated QR
/// code on the provided [assets/KHQR_card.svg] template with a countdown,
/// and a manual "I've paid" confirm button since there's no real Bakong
/// backend/webhook to detect a scan against.
class _KhqrPaymentSheet extends StatefulWidget {
  const _KhqrPaymentSheet({
    required this.amount,
    required this.currency,
    required this.showBoth,
  });

  final double amount;
  final AppCurrency currency;
  final bool showBoth;

  @override
  State<_KhqrPaymentSheet> createState() => _KhqrPaymentSheetState();
}

class _KhqrPaymentSheetState extends State<_KhqrPaymentSheet> {
  static const _initialSeconds = 5 * 60;

  int _secondsLeft = _initialSeconds;
  late String _qrData;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _qrData = _generateQrPayload();
    _startTimer();
  }

  String _generateQrPayload() {
    final khr = ((widget.amount * _kMockKhrPerUsd) / 100).round() * 100;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return 'KHQR-BOSDOM-$khr-$stamp';
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  void _refreshCode() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = _initialSeconds;
      _qrData = _generateQrPayload();
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    final expired = _secondsLeft == 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
                const SizedBox(height: 6),
                Text(
                  l10n.paymentKhqrInstructions,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: AnimatedOpacity(
                      opacity: expired ? 0.35 : 1,
                      duration: const Duration(milliseconds: 250),
                      child: _KhqrCardVisual(
                        amountUsd: widget.amount,
                        currency: widget.currency,
                        showBoth: widget.showBoth,
                        qrData: _qrData,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: expired
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.paymentKhqrExpiredLabel,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _refreshCode,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(l10n.paymentKhqrRefreshButton),
                            ),
                          ],
                        )
                      : Row(
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
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: expired
                        ? null
                        : () => Navigator.of(context).pop(true),
                    child: Text(l10n.paymentKhqrConfirmButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Renders [assets/KHQR_card.svg] as a card background and overlays the
/// merchant name, KHR amount, and a generated QR code on top of it, using
/// the SVG's fixed viewBox geometry (442x622) to place each element
/// proportionally regardless of the rendered size.
class _KhqrCardVisual extends StatelessWidget {
  const _KhqrCardVisual({
    required this.amountUsd,
    required this.currency,
    required this.showBoth,
    required this.qrData,
  });

  final double amountUsd;
  final AppCurrency currency;
  final bool showBoth;
  final String qrData;

  static const _svgWidth = 442.0;
  static const _svgHeight = 622.0;
  static const _headerBottomFraction = 90.6 / _svgHeight;
  static const _dashedLineFraction = 218.5 / _svgHeight;
  static const _cardLeftFraction = 21.0 / _svgWidth;
  static const _cardRightFraction = 421.0 / _svgWidth;
  static const _cardBottomFraction = 601.0 / _svgHeight;

  @override
  Widget build(BuildContext context) {
    final String amountPrefix;
    final String amountLabel;
    final String amountSuffix;
    final String secondaryAmount;
    final khr = ((amountUsd * _kMockKhrPerUsd) / 100).round() * 100;
    if (currency == AppCurrency.usd) {
      amountPrefix = r'$';
      amountLabel = NumberFormat('#,##0.00', 'en_US').format(amountUsd);
      amountSuffix = '  USD';
      secondaryAmount = '≈ ៛${NumberFormat('#,##0', 'en_US').format(khr)}';
    } else {
      amountPrefix = '';
      amountLabel = NumberFormat('#,##0', 'en_US').format(khr);
      amountSuffix = '  KHR';
      secondaryAmount =
          '≈ \$${NumberFormat('#,##0.00', 'en_US').format(amountUsd)}';
    }

    return AspectRatio(
      aspectRatio: _svgWidth / _svgHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return Stack(
            children: [
              SvgPicture.asset(
                'assets/KHQR_card.svg',
                width: width,
                height: height,
                fit: BoxFit.fill,
              ),
              Positioned(
                top: height * _headerBottomFraction + height * 0.03,
                left: width * _cardLeftFraction + width * 0.03,
                right: width * (1 - _cardRightFraction) + width * 0.03,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BosDom Marketplace',
                      style: TextStyle(
                        fontSize: height * 0.026,
                        color: AppColors.warmTaupe,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: height * 0.012),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '$amountPrefix$amountLabel',
                            style: TextStyle(
                              fontSize: height * 0.05,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warmBlack,
                            ),
                          ),
                          TextSpan(
                            text: amountSuffix,
                            style: TextStyle(
                              fontSize: height * 0.022,
                              color: AppColors.warmTaupe,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showBoth) ...[
                      SizedBox(height: height * 0.006),
                      Text(
                        secondaryAmount,
                        style: TextStyle(
                          fontSize: height * 0.022,
                          color: AppColors.warmTaupe,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                top: height * _dashedLineFraction + height * 0.045,
                left: 0,
                right: 0,
                bottom: height * (1 - _cardBottomFraction) + height * 0.025,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: EdgeInsets.all(width * 0.02),
                      child: QrImageView(
                        data: qrData,
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
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
