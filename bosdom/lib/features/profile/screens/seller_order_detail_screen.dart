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
import '../../marketplace/widgets/empty_products_notice.dart';
import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/services/dispute_service.dart';
import '../../orders/services/order_service.dart';
import '../../orders/widgets/fulfilment_sheets.dart';
import '../../orders/widgets/order_hold_card.dart';
import '../../orders/widgets/seller_report_sheet.dart';
import '../../orders/widgets/release_flow_card.dart';
import '../../orders/services/receipt_service.dart';
import '../models/seller_order.dart';

// Same header size/shape as the seller dashboard/orders screens so moving
// between seller screens feels like the same app.
const _kHeaderContentHeight = 68.0;

class SellerOrderDetailScreen extends ConsumerWidget {
  const SellerOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));
    return orderAsync.when(
      data: (order) => _SellerOrderDetailBody(order: order),
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

class _SellerOrderDetailBody extends ConsumerStatefulWidget {
  const _SellerOrderDetailBody({required this.order});

  final Order order;

  @override
  ConsumerState<_SellerOrderDetailBody> createState() =>
      _SellerOrderDetailBodyState();
}

class _SellerOrderDetailBodyState
    extends ConsumerState<_SellerOrderDetailBody> {
  bool _isSavingReceipt = false;
  bool _isConfirming = false;

  Future<void> _confirmOrder(Order order) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isConfirming = true);
    try {
      await OrderService.confirmOrder(order.id);
      ref.invalidate(orderByIdProvider(order.id));
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: l10n.sellerOrderDetailConfirmFailedSnackbar('$e'),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  Future<void> _fulfil(Order order, {required bool delivering}) async {
    final done = delivering
        ? await showDeliveryProofSheet(context, order)
        : await showShipOrderSheet(context, order);
    if (!done) return;
    ref.invalidate(orderByIdProvider(order.id));
    ref.invalidate(sellerOrdersProvider);
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
                    title: l10n.sellerOrderDetailBuyerInfoSection,
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
                  if (order.status != OrderStatus.pendingPayment &&
                      order.status != OrderStatus.cancelled) ...[
                    const SizedBox(height: 16),
                    ReleaseFlowCard(order: order),
                  ],
                  if (order.status == OrderStatus.disputed) ...[
                    const SizedBox(height: 16),
                    if (order.holdSource == 'delivery')
                      OrderHoldCard(order: order, forSeller: true)
                    else
                      _DisputeCaseCard(order: order),
                  ],
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
                              child: Text(
                                l10n.reviewEmptyStateMessage,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (order.status == OrderStatus.held) ...[
                    if (order.isDelivered)
                      _InfoLine(
                        icon: Icons.timer_outlined,
                        text: l10n.escrowSellerWaitingTimer,
                      )
                    else if (order.isShipped)
                      const SizedBox.shrink()
                    else if (order.isSellerConfirmed)
                      FilledButton.icon(
                        onPressed: () => _fulfil(order, delivering: false),
                        icon: const Icon(Icons.local_shipping_outlined),
                        label: Text(l10n.escrowShipButton),
                      )
                    else
                      FilledButton.icon(
                        onPressed: _isConfirming
                            ? null
                            : () => _confirmOrder(order),
                        icon: _isConfirming
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.task_alt_rounded),
                        label: Text(
                          _isConfirming
                              ? l10n.sellerOrderDetailConfirmingLabel
                              : l10n.sellerOrderDetailConfirmButton,
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
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
                  if (order.status == OrderStatus.held &&
                      (order.isShipped || order.isDelivered)) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => showSellerReportSheet(context, order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                      ),
                      icon: const Icon(Icons.report_gmailerrorred_outlined),
                      label: Text(l10n.sellerReportButton),
                    ),
                  ],
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderDetailOrderNumberLabel(order.displayNumber),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            label: sellerOrderStatusLabel(
              order.status,
              isSellerConfirmed: order.isSellerConfirmed,
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

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.trustGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// The buyer's reported problem as the seller sees it: once the admin opens
/// the case, the seller writes their side here.
class _DisputeCaseCard extends StatefulWidget {
  const _DisputeCaseCard({required this.order});

  final Order order;

  @override
  State<_DisputeCaseCard> createState() => _DisputeCaseCardState();
}

class _DisputeCaseCardState extends State<_DisputeCaseCard> {
  late Future<OrderDispute?> _future = DisputeService.fetchForOrder(
    widget.order.id,
  );
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(OrderDispute dispute) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _sending = true);
    try {
      await DisputeService.sellerReply(dispute.id, text);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _future = DisputeService.fetchForOrder(widget.order.id);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      showAppSnackBar(
        context,
        message: l10n.escrowActionFailed('$e'),
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: FutureBuilder<OrderDispute?>(
        future: _future,
        builder: (context, snapshot) {
          final dispute = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.escrowSellerReplyTitle.toUpperCase(),
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.escrowSellerDisputed,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (dispute != null) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.escrowSellerReplyReported(
                    dispute.reason.replaceAll('_', ' '),
                  ),
                  style: textTheme.bodyMedium,
                ),
                if (dispute.note.isNotEmpty)
                  Text(
                    dispute.note,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                const SizedBox(height: 12),
                if (dispute.sellerResponse != null) ...[
                  Text(
                    l10n.escrowSellerReplySent,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(dispute.sellerResponse!),
                ] else if (dispute.isCaseOpen) ...[
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.escrowSellerReplyHint,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _sending ? null : () => _send(dispute),
                    child: Text(l10n.escrowSellerReplyButton),
                  ),
                ] else
                  Text(
                    l10n.escrowSellerReplyWaiting,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}
