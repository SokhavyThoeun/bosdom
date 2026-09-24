import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/services/shipping_fee_calculator.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/checkout_progress_stepper.dart';
import '../../../shared/widgets/price_display.dart';
import '../../co_buying/providers/co_buy_provider.dart';
import '../../co_buying/services/co_buy_pool_service.dart'
    show CoBuyJoinException;
import '../../payment/screens/payment_screen.dart' show OrderLineSummary;
import '../../profile/providers/profile_provider.dart';
import '../../../shared/utils/mock_images.dart';
import '../models/address.dart';
import '../providers/address_provider.dart';

class CheckoutLineItem {
  const CheckoutLineItem({
    required this.icon,
    required this.imageUrl,
    required this.name,
    required this.qtyLabel,
    required this.total,
    required this.seller,
    this.sellerLogoOverride,
    this.listingId,
    this.quantity = 1,
    // Co-buy sessions don't track a per-item weight yet, so this falls back
    // to a rough average wholesale-carton estimate rather than 0 (which
    // would silently understate the shipping estimate to nothing).
    this.weightKg = 1.0,
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

  /// Purchased quantity as a real int (distinct from [qtyLabel]'s display
  /// string), needed to create a real backend order.
  final int quantity;

  /// Total weight for this line (already accounts for quantity) — used to
  /// pick the right weight bracket in [estimateShippingFee].
  final double weightKg;

  /// The seller's real shop logo when available, else a generated mock logo.
  String get sellerLogoUrl => sellerLogoOverride ?? mockStoreLogoUrl(seller);
}

class _ShippingOption {
  const _ShippingOption({
    required this.id,
    required this.name,
    required this.logoAsset,
  });

  final String id;
  final String name;
  final String logoAsset;
}

final _kCheckoutItems = [
  CheckoutLineItem(
    icon: Icons.rice_bowl_outlined,
    imageUrl: mockPhotoUrl('jasmine,rice,bag', 'checkout-rice'),
    name: 'Premium Jasmine Rice (25kg)',
    qtyLabel: 'Qty: 20 Bags',
    quantity: 20,
    total: 370,
    seller: 'Mekong Agri-Food Co.',
    weightKg: 500, // 20 bags × 25kg
  ),
  CheckoutLineItem(
    icon: Icons.local_cafe_outlined,
    imageUrl: mockPhotoUrl('paper,cup', 'checkout-cups'),
    name: 'Biodegradable Paper Hot Cups',
    qtyLabel: 'Qty: 5 Boxes',
    quantity: 5,
    total: 80,
    seller: 'EcoPack Cambodia',
    weightKg: 2.5, // 5 boxes × 0.5kg
  ),
  CheckoutLineItem(
    icon: Icons.bolt_outlined,
    imageUrl: mockPhotoUrl('usb,charger', 'checkout-usb'),
    name: 'Universal USB-C Bulk Pack',
    qtyLabel: 'Qty: 100 Units',
    quantity: 100,
    total: 320,
    seller: 'PP Tech Import',
    weightKg: 5, // 100 units × 0.05kg
  ),
];

// Every seller in this dataset ships from Phnom Penh.
const _kOriginProvince = 'Phnom Penh';

const _kShippingOptions = [
  _ShippingOption(
    id: 'vireak',
    name: kVireakBunthamCarrier,
    logoAsset: 'assets/images/shipping/vet-express.png',
  ),
  _ShippingOption(
    id: 'jt',
    name: kJtExpressCarrier,
    logoAsset: 'assets/images/shipping/jt-express.png',
  ),
  _ShippingOption(
    id: 'grab',
    name: kGrabExpressCarrier,
    logoAsset: 'assets/images/shipping/grab-express.png',
  ),
];

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, this.items, this.coBuyPoolId});

  final List<CheckoutLineItem>? items;

  /// Set when this checkout is for a co-buy join: the reservation is released
  /// if the buyer backs out, and the id is forwarded so payment holds it.
  final String? coBuyPoolId;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedShippingId = _kShippingOptions.first.id;

  /// Backing out of a co-buy checkout leaves a stale pending_payment
  /// reservation behind — release it so the deal shows "Join Co-Buy" again.
  void _cancelStaleCoBuyJoinOnExit() {
    final coBuyPoolId = widget.coBuyPoolId;
    if (coBuyPoolId == null) return;
    final notifier = ref.read(coBuyProvider.notifier);
    unawaited(() async {
      try {
        await notifier.leave(coBuyPoolId);
      } on CoBuyJoinException {
        // Already resolved through another path — nothing left to clean up.
      }
    }());
  }

  List<CheckoutLineItem> get _items => widget.items ?? _kCheckoutItems;

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);

  double get _totalWeightKg =>
      _items.fold(0, (sum, item) => sum + item.weightKg);

  /// Every offered carrier's live quote for this shipment's actual weight
  /// and route, keyed by [_ShippingOption.id] — `null` where the carrier
  /// can't serve this weight/route at all (e.g. Grab Express outside
  /// Phnom Penh, or a shipment over a carrier's parcel weight cap).
  Map<String, ShippingQuote?> _shippingQuotes(String destinationProvince) => {
    for (final option in _kShippingOptions)
      option.id: estimateShippingFee(
        carrier: option.name,
        weightKg: _totalWeightKg,
        originProvince: _kOriginProvince,
        destinationProvince: destinationProvince,
      ),
  };

  /// Falls back to the first carrier that can actually serve this shipment
  /// when the selected one can't (e.g. the buyer picked Grab Express, then
  /// switched their address outside Phnom Penh).
  String _effectiveShippingId(Map<String, ShippingQuote?> quotes) {
    if (quotes[_selectedShippingId] != null) return _selectedShippingId;
    return quotes.entries
        .firstWhere(
          (entry) => entry.value != null,
          orElse: () => quotes.entries.first,
        )
        .key;
  }

  double _escrowFee(double shipping) => (_subtotal + shipping) * 0.02;

  double _total(double shipping) => _subtotal + shipping + _escrowFee(shipping);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final defaultAddress = ref.watch(defaultAddressProvider);
    final profile = ref.watch(profileProvider).value;
    final destinationProvince = defaultAddress?.province ?? _kOriginProvince;
    final shippingQuotes = _shippingQuotes(destinationProvince);
    final effectiveShippingId = _effectiveShippingId(shippingQuotes);
    final shipping = shippingQuotes[effectiveShippingId]?.fee ?? 0.0;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) _cancelStaleCoBuyJoinOnExit();
      },
      child: Scaffold(
        body: Column(
          children: [
            _CheckoutHeader(colorScheme: colorScheme, textTheme: textTheme),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    20,
                    16,
                    8 + MediaQuery.of(context).padding.bottom,
                  ),
                  children: [
                    const CheckoutProgressStepper(
                      currentStep: CheckoutStep.checkout,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.checkoutDeliveryAddressLabel,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DeliveryAddressCard(
                      address: defaultAddress,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 20),
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
                          l10n.checkoutItemsCount(_items.length),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _OrderItemsCard(
                      items: _items,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.checkoutShippingMethodLabel,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final option in _kShippingOptions) ...[
                      _ShippingOptionTile(
                        option: option,
                        quote: shippingQuotes[option.id],
                        selected: option.id == effectiveShippingId,
                        onTap: () =>
                            setState(() => _selectedShippingId = option.id),
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 10),
                    _OrderSummaryCard(
                      subtotal: _subtotal,
                      shipping: shipping,
                      escrowFee: _escrowFee(shipping),
                      total: _total(shipping),
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.checkoutEscrowNotice,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.pushNamed(
                        'payment',
                        extra: {
                          'amount': _total(shipping),
                          'itemCount': _items.length,
                          'coBuyPoolId': widget.coBuyPoolId,
                          'shippingName': profile?.name ?? '',
                          'shippingAddress': defaultAddress == null
                              ? ''
                              : '${defaultAddress.addressLine}, ${defaultAddress.cityLine}',
                          'shippingPhone':
                              defaultAddress?.phone ?? profile?.phone ?? '',
                          'items': [
                            for (final item in _items)
                              OrderLineSummary(
                                icon: item.icon,
                                imageUrl: item.imageUrl,
                                name: item.name,
                                qtyLabel: item.qtyLabel,
                                total: item.total,
                                seller: item.seller,
                                sellerLogoOverride: item.sellerLogoOverride,
                                listingId: item.listingId,
                                quantity: item.quantity,
                              ),
                          ],
                        },
                      ),
                      child: Text(l10n.checkoutContinueToPayment),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Sized to fit a back-row + centered title, shorter than the two-row
// home/search header since there's no search bar to fit.
const _kHeaderContentHeight = 68.0;

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.colorScheme, required this.textTheme});

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
                l10n.checkoutScreenTitle,
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

class _DeliveryAddressCard extends StatelessWidget {
  const _DeliveryAddressCard({
    required this.address,
    required this.colorScheme,
    required this.textTheme,
  });

  final Address? address;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final address = this.address;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: address == null
                ? Text(
                    l10n.checkoutNoAddressYet,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address.label,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address.cityLine,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
          ),
          TextButton(
            onPressed: () => context.pushNamed('addressBook', extra: true),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.checkoutChangeAddress,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({
    required this.items,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<CheckoutLineItem> items;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<CheckoutLineItem>>{};
    for (final item in items) {
      groups.putIfAbsent(item.seller, () => []).add(item);
    }

    return Column(
      children: [
        for (final entry in groups.entries) ...[
          _SellerGroupCard(
            seller: entry.key,
            items: entry.value,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          if (entry.key != groups.keys.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SellerGroupCard extends ConsumerWidget {
  const _SellerGroupCard({
    required this.seller,
    required this.items,
    required this.colorScheme,
    required this.textTheme,
  });

  final String seller;
  final List<CheckoutLineItem> items;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: colorScheme.primaryContainer,
                child: ClipOval(
                  child: Image.network(
                    items.first.sellerLogoUrl,
                    width: 22,
                    height: 22,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : Icon(
                            Icons.storefront_outlined,
                            size: 13,
                            color: colorScheme.primary,
                          ),
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.storefront_outlined,
                      size: 13,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  seller,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.checkoutItemsCount(items.length),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          for (final item in items) ...[
            Divider(color: colorScheme.outlineVariant, height: 20),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : Icon(item.icon, color: colorScheme.primary, size: 20),
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(item.icon, color: colorScheme.primary, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.qtyLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatPrice(ref, item.total),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ShippingOptionTile extends ConsumerWidget {
  const _ShippingOptionTile({
    required this.option,
    required this.quote,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final _ShippingOption option;
  final ShippingQuote? quote;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final quote = this.quote;
    final available = quote != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: available ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Opacity(
          opacity: available ? 1 : 0.5,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected && available
                    ? colorScheme.primary
                    : colorScheme.outline,
                width: selected && available ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    option.logoAsset,
                    width: 56,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              option.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (available) ...[
                            const SizedBox(width: 8),
                            Text(
                              formatPrice(ref, quote.fee),
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        available
                            ? quote.etaLabel
                            : l10n.checkoutShippingUnavailableLabel,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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

class _OrderSummaryCard extends ConsumerWidget {
  const _OrderSummaryCard({
    required this.subtotal,
    required this.shipping,
    required this.escrowFee,
    required this.total,
    required this.colorScheme,
    required this.textTheme,
  });

  final double subtotal;
  final double shipping;
  final double escrowFee;
  final double total;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.checkoutOrderSummaryTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: l10n.checkoutSubtotal,
            value: subtotal,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.checkoutShippingLabel,
            value: shipping,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.checkoutEscrowFeeLabel,
            value: escrowFee,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const Divider(height: 24),
          Row(
            children: [
              Text(
                l10n.checkoutTotalAmount,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              PriceDisplay(
                total,
                crossAxisAlignment: CrossAxisAlignment.end,
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final double value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          formatPrice(ref, value),
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
