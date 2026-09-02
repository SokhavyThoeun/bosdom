import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/checkout_progress_stepper.dart';
import '../../payment/screens/payment_screen.dart' show OrderLineSummary;
import '../../../shared/utils/mock_images.dart';
import '../models/address.dart';
import '../providers/address_provider.dart';

class CheckoutLineItem {
  const CheckoutLineItem({
    required this.icon,
    required this.name,
    required this.qtyLabel,
    required this.total,
    required this.seller,
  });

  final IconData icon;
  final String name;
  final String qtyLabel;
  final double total;
  final String seller;
}

class _ShippingOption {
  const _ShippingOption({
    required this.id,
    required this.name,
    required this.description,
    required this.logoAsset,
  });

  final String id;
  final String name;
  final String description;
  final String logoAsset;
}

const _kCheckoutItems = [
  CheckoutLineItem(
    icon: Icons.rice_bowl_outlined,
    name: 'Premium Jasmine Rice (25kg)',
    qtyLabel: 'Qty: 20 Bags',
    total: 370,
    seller: 'Mekong Agri-Food Co.',
  ),
  CheckoutLineItem(
    icon: Icons.local_cafe_outlined,
    name: 'Biodegradable Paper Hot Cups',
    qtyLabel: 'Qty: 5 Boxes',
    total: 80,
    seller: 'EcoPack Cambodia',
  ),
  CheckoutLineItem(
    icon: Icons.bolt_outlined,
    name: 'Universal USB-C Bulk Pack',
    qtyLabel: 'Qty: 100 Units',
    total: 320,
    seller: 'PP Tech Import',
  ),
];

const _kShippingOptions = [
  _ShippingOption(
    id: 'vireak',
    name: 'Vireak Buntham Express',
    description: 'Standard delivery · 1-2 days',
    logoAsset: 'assets/images/shipping/vet-express.png',
  ),
  _ShippingOption(
    id: 'jt',
    name: 'J&T Express',
    description: 'Standard delivery · 1-2 days',
    logoAsset: 'assets/images/shipping/jt-express.png',
  ),
  _ShippingOption(
    id: 'grab',
    name: 'Grab Express',
    description: 'Phnom Penh only · Fast Delivery',
    logoAsset: 'assets/images/shipping/grab-express.png',
  ),
];

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, this.items});

  final List<CheckoutLineItem>? items;

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedShippingId = _kShippingOptions.first.id;

  List<CheckoutLineItem> get _items => widget.items ?? _kCheckoutItems;

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);

  double get _shipping => 2.0;

  double get _escrowFee => (_subtotal + _shipping) * 0.02;

  double get _total => _subtotal + _shipping + _escrowFee;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final defaultAddress = ref.watch(defaultAddressProvider);

    return Scaffold(
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
                      selected: option.id == _selectedShippingId,
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
                    shipping: _shipping,
                    escrowFee: _escrowFee,
                    total: _total,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.cancel, size: 16, color: colorScheme.primary),
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
                        'amount': _total,
                        'itemCount': _items.length,
                        'items': [
                          for (final item in _items)
                            OrderLineSummary(
                              icon: item.icon,
                              name: item.name,
                              qtyLabel: item.qtyLabel,
                              total: item.total,
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
    );
  }
}

// Matches the combined height of the logo/notification row + search bar
// used by the homepage and wishlist headers, so this header is the same
// overall size even though it shows a back row + centered title.
const _kHeaderContentHeight = 96.0;

class _CheckoutHeader extends StatelessWidget {
  const _CheckoutHeader({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 16,
          24,
          20,
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.commonBack,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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

class _SellerGroupCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                    mockStoreLogoUrl(seller),
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
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: colorScheme.primary, size: 20),
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
                  '\$${item.total.toStringAsFixed(2)}',
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

class _ShippingOptionTile extends StatelessWidget {
  const _ShippingOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final _ShippingOption option;
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outline,
              width: selected ? 2 : 1,
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
                    Text(
                      option.name,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
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
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              Text(
                '\$${total.toStringAsFixed(2)}',
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

class _SummaryRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
          '\$${value.toStringAsFixed(2)}',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
