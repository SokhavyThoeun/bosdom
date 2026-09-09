import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/delivery_carrier.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../cart/providers/cart_provider.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../services/receipt_service.dart';

// All statuses share the brand color instead of a traffic-light palette —
// status is distinguished by icon and label, not by hue.
Color _statusColor(OrderStatus status) => AppColors.brandCrimson;

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _isSavingReceipt = false;

  Order _order(List<Order> orders) => orders.firstWhere(
    (order) => order.id == widget.orderId,
    orElse: () => orders.first,
  );

  Future<void> _saveReceipt(Order order) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSavingReceipt = true);
    try {
      final pdfBytes = await ReceiptService.generateReceiptPdf(order);
      await FileSaver.instance.saveFile(
        name: 'receipt-${order.id}',
        bytes: pdfBytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: l10n.orderDetailReceiptSavedSnackbar,
        type: AppSnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: l10n.orderDetailReceiptSaveFailedSnackbar('$e'),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isSavingReceipt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final order = _order(ref.watch(ordersProvider));
    final statusColor = _statusColor(order.status);
    final carrierLogoAsset = deliveryLogoAsset(order.deliveryMethod);

    void reorder() {
      ref.read(cartProvider.notifier).addItems([
        for (final item in order.items) (item.product, item.quantity),
      ]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderDetailItemsAddedSnackbar)),
      );
      context.goNamed('cart');
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
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
                  _OrderSummaryHeader(
                    order: order,
                    statusColor: statusColor,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: l10n.orderDetailItemsOrderedSection,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    child: Column(
                      children: [
                        for (final item in order.items) ...[
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Image.network(
                                    item.product.imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, progress) =>
                                            progress == null
                                            ? child
                                            : Icon(
                                                item.product.icon,
                                                color: colorScheme.primary,
                                                size: 20,
                                              ),
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          item.product.icon,
                                          color: colorScheme.primary,
                                          size: 20,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.name,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.product.seller,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.primary,
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
                                const SizedBox(width: 12),
                                Text(
                                  '\$${item.lineTotal.toStringAsFixed(2)}',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: l10n.orderDetailShippingSection,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.shippingName,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.shippingAddress,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.orderDetailPhoneLabel(order.shippingPhone),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: l10n.orderDetailDeliveryMethodSection,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: carrierLogoAsset != null
                              ? Image.asset(
                                  carrierLogoAsset,
                                  width: 56,
                                  height: 42,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 56,
                                  height: 42,
                                  alignment: Alignment.center,
                                  color: colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.local_shipping_outlined,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.orderDetailCarrierLabel,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.deliveryMethod,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: l10n.orderDetailPaymentSummarySection,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SummaryRow(
                          label: l10n.orderDetailSubtotalLabel,
                          valueLabel: '\$${order.subtotal.toStringAsFixed(2)}',
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        if (order.discount > 0) ...[
                          const SizedBox(height: 8),
                          _SummaryRow(
                            label: l10n.orderDetailWholesaleDiscountLabel,
                            valueLabel:
                                '-\$${order.discount.toStringAsFixed(2)}',
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                        ],
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: l10n.orderDetailShippingFeeLabel,
                          valueLabel: order.shippingFeeLabel,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            Text(
                              l10n.orderDetailTotalAmountLabel,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '\$${order.total.toStringAsFixed(2)}',
                              style: textTheme.titleLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => context.pushNamed(
                      'deliveryTracking',
                      pathParameters: {'id': order.id},
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                    child: Text(l10n.orderDetailTrackDeliveryButton),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _isSavingReceipt
                        ? null
                        : () => _saveReceipt(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                    icon: _isSavingReceipt
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          )
                        : const Icon(Icons.file_download_outlined),
                    label: Text(
                      _isSavingReceipt
                          ? l10n.orderDetailSavingLabel
                          : l10n.orderDetailSaveReceiptButton,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: reorder,
                    child: Text(l10n.orderDetailReorderButton),
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

class _Header extends StatelessWidget {
  const _Header({required this.colorScheme, required this.textTheme});

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
                    child: Icon(
                      Icons.arrow_back,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Text(
                l10n.orderDetailScreenTitle,
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

class _OrderSummaryHeader extends StatelessWidget {
  const _OrderSummaryHeader({
    required this.order,
    required this.statusColor,
    required this.colorScheme,
    required this.textTheme,
  });

  final Order order;
  final Color statusColor;
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderDetailOrderNumberLabel(order.id),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.orderDetailPlacedOnLabel(order.date),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.status.label,
              style: textTheme.labelMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    required this.colorScheme,
    required this.textTheme,
  });

  final String title;
  final Widget child;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
            title.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.valueLabel,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final String valueLabel;
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
          valueLabel,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
