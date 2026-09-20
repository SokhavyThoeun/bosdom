import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/price_display.dart';
import '../../../shared/widgets/order_review_card.dart';
import '../../../shared/widgets/order_status_badge.dart';
import '../../cart/providers/cart_provider.dart';
import '../../marketplace/providers/listings_provider.dart';
import '../../marketplace/widgets/empty_products_notice.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../services/order_service.dart';
import '../services/receipt_service.dart';
import '../widgets/order_hold_card.dart';
import 'rate_review_sheet.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));
    return orderAsync.when(
      data: (order) => _OrderDetailBody(order: order),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return Scaffold(
          body: Center(
            child: EmptyProductsNotice(
              colorScheme: colorScheme,
              textTheme: textTheme,
              message: AppLocalizations.of(context).ordersLoadError,
              onRetry: () => ref.invalidate(orderByIdProvider(orderId)),
            ),
          ),
        );
      },
    );
  }
}

class _OrderDetailBody extends ConsumerStatefulWidget {
  const _OrderDetailBody({required this.order});

  final Order order;

  @override
  ConsumerState<_OrderDetailBody> createState() => _OrderDetailBodyState();
}

class _OrderDetailBodyState extends ConsumerState<_OrderDetailBody> {
  bool _isSavingReceipt = false;
  bool _isReordering = false;
  bool _isConfirmingReceipt = false;

  /// Buyer confirming the item arrived: releases the escrow, which lands the
  /// money in the seller's earnings balance for them to withdraw.
  Future<void> _confirmReceived(Order order) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isConfirmingReceipt = true);
    try {
      await OrderService.releaseOrder(order.id);
      ref.invalidate(orderByIdProvider(order.id));
      ref.invalidate(ordersProvider);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: l10n.orderDetailConfirmReceivedFailedSnackbar('$e'),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isConfirmingReceipt = false);
    }
  }

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

  /// The order only snapshots the listing's id, not a full [Product], so
  /// reordering re-fetches the live listing rather than reusing anything
  /// carried on the order itself.
  Future<void> _reorder(Order order) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isReordering = true);
    try {
      final product = await ref.read(
        listingByIdProvider(order.listingId).future,
      );
      if (!mounted) return;
      final succeeded = await ref.read(cartProvider.notifier).addItems([
        (product, order.quantity),
      ]);
      if (!mounted) return;
      if (!succeeded) {
        throw Exception(l10n.cartUpdateErrorSnackbar);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.orderDetailItemsAddedSnackbar)),
      );
      context.goNamed('cart');
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: l10n.orderDetailReorderFailedSnackbar('$e'),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isReordering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final order = widget.order;

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
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: l10n.orderDetailItemsOrderedSection,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outlineVariant),
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
                            child: order.imageUrl == null
                                ? Icon(
                                    order.icon,
                                    color: colorScheme.primary,
                                    size: 20,
                                  )
                                : Image.network(
                                    order.imageUrl!,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, progress) =>
                                            progress == null
                                            ? child
                                            : Icon(
                                                order.icon,
                                                color: colorScheme.primary,
                                                size: 20,
                                              ),
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          order.icon,
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
                                  order.productName,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.ordersItemCountLabel(order.quantity),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatPrice(ref, order.totalAmount),
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (order.status == OrderStatus.disputed &&
                      order.holdSource != null) ...[
                    const SizedBox(height: 16),
                    OrderHoldCard(order: order),
                  ],
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
                    title: l10n.orderDetailPaymentSummarySection,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SummaryRow(
                          label: l10n.orderDetailUnitPriceLabel,
                          valueLabel: formatPrice(ref, order.unitPrice),
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: l10n.orderDetailQuantityLabel,
                          valueLabel: '${order.quantity}',
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
                            PriceDisplay(
                              order.totalAmount,
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
                  ),
                  if (order.status == OrderStatus.released) ...[
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: l10n.reviewSectionTitle,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      child: order.review != null
                          ? OrderReviewCard(review: order.review!)
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () =>
                                      showRateReviewSheet(context, order),
                                  icon: const Icon(Icons.star_outline_rounded),
                                  label: Text(l10n.ordersRateReviewButton),
                                ),
                              ),
                            ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (order.status == OrderStatus.held && order.isShipped) ...[
                    FilledButton.icon(
                      onPressed: _isConfirmingReceipt
                          ? null
                          : () => _confirmReceived(order),
                      icon: _isConfirmingReceipt
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.inventory_2_outlined),
                      label: Text(
                        _isConfirmingReceipt
                            ? l10n.orderDetailConfirmReceivingLabel
                            : l10n.orderDetailConfirmReceivedButton,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
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
                    onPressed: _isReordering ? null : () => _reorder(order),
                    child: _isReordering
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.orderDetailReorderButton),
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
    required this.colorScheme,
    required this.textTheme,
  });

  final Order order;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.orderDetailOrderNumberLabel(order.displayNumber),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.orderDetailPlacedOnLabel(order.dateLabel),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              OrderStatusBadge(
                label: buyerOrderStatusLabel(
                  order.status,
                  isSellerConfirmed: order.isSellerConfirmed,
                ),
              ),
            ],
          ),
          if (order.status == OrderStatus.held) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  order.isSellerConfirmed
                      ? Icons.task_alt_rounded
                      : Icons.schedule,
                  size: 16,
                  color: order.isSellerConfirmed
                      ? AppColors.trustGreen
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  order.isSellerConfirmed
                      ? l10n.orderDetailSellerConfirmedLabel
                      : l10n.orderDetailAwaitingSellerConfirmationLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
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
