import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/order_status_badge.dart';
import '../../marketplace/widgets/empty_products_notice.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';
import 'rate_review_sheet.dart';
import 'report_order_sheet.dart';

// `OrderStatus.held` covers two buyer-visible states depending on whether
// the seller has confirmed yet, so filters are keyed on (status,
// isSellerConfirmed) rather than the raw enum — see [Order.isSellerConfirmed].
typedef _StatusFilter = ({OrderStatus status, bool isSellerConfirmed});

// `pendingPayment`/`disputed` are excluded here — those escrow states
// belong to the seller's earnings dashboard; a buyer still sees the real
// status badge on an order that happens to be in one of them, but can't
// filter the list down to just those.
const _kStatusFilters = <_StatusFilter>[
  (status: OrderStatus.held, isSellerConfirmed: false),
  (status: OrderStatus.held, isSellerConfirmed: true),
  (status: OrderStatus.released, isSellerConfirmed: true),
  (status: OrderStatus.refunded, isSellerConfirmed: true),
  (status: OrderStatus.cancelled, isSellerConfirmed: true),
];

const _kFilters = [null, ..._kStatusFilters];

IconData _statusIcon(OrderStatus status, {bool isSellerConfirmed = true}) =>
    switch (status) {
      OrderStatus.pendingPayment => Icons.hourglass_top_rounded,
      OrderStatus.held =>
        isSellerConfirmed
            ? Icons.inventory_2_outlined
            : Icons.receipt_long_outlined,
      OrderStatus.released => Icons.check_circle_rounded,
      OrderStatus.disputed => Icons.report_problem_rounded,
      OrderStatus.refunded => Icons.undo_rounded,
      OrderStatus.cancelled => Icons.cancel_rounded,
    };

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  _StatusFilter? _filter;

  List<Order> _filteredOrders(List<Order> orders) {
    final filter = _filter;
    if (filter == null) return orders;
    return orders
        .where(
          (order) =>
              order.status == filter.status &&
              order.isSellerConfirmed == filter.isSellerConfirmed,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: ordersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: EmptyProductsNotice(
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    message: l10n.ordersLoadError,
                    onRetry: () => ref.read(ordersProvider.notifier).refresh(),
                  ),
                ),
                data: (orders) {
                  final filteredOrders = _filteredOrders(orders);
                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.read(ordersProvider.notifier).refresh(),
                    color: colorScheme.primary,
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                          sliver: SliverToBoxAdapter(
                            child: _FilterRow(
                              selected: _filter,
                              onSelected: (status) =>
                                  setState(() => _filter = status),
                              orderCount: orders.length,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                          ),
                        ),
                        if (filteredOrders.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _EmptyState(
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                          )
                        else
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              16,
                              24,
                              8 + MediaQuery.of(context).padding.bottom,
                            ),
                            sliver: SliverList.separated(
                              itemCount: filteredOrders.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) => _OrderCard(
                                order: filteredOrders[index],
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                                onViewDetails: () => context.pushNamed(
                                  'orderDetail',
                                  pathParameters: {
                                    'id': filteredOrders[index].id,
                                  },
                                ),
                                onReport: () => showReportOrderSheet(
                                  context,
                                  filteredOrders[index],
                                ),
                                onRate: () => showRateReviewSheet(
                                  context,
                                  filteredOrders[index],
                                ),
                                onTrack: () => context.pushNamed(
                                  'deliveryTracking',
                                  pathParameters: {
                                    'id': filteredOrders[index].id,
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
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
                l10n.ordersScreenTitle,
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

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selected,
    required this.onSelected,
    required this.orderCount,
    required this.colorScheme,
    required this.textTheme,
  });

  final _StatusFilter? selected;
  final ValueChanged<_StatusFilter?> onSelected;
  final int orderCount;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _kFilters.length; i++) ...[
            _FilterChip(
              label: _kFilters[i] == null
                  ? l10n.ordersFilterAllLabel(orderCount)
                  : buyerOrderStatusLabel(
                      _kFilters[i]!.status,
                      isSellerConfirmed: _kFilters[i]!.isSellerConfirmed,
                    ),
              isSelected: selected == _kFilters[i],
              onTap: () => onSelected(_kFilters[i]),
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            if (i != _kFilters.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? colorScheme.primary : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends ConsumerWidget {
  const _OrderCard({
    required this.order,
    required this.colorScheme,
    required this.textTheme,
    required this.onViewDetails,
    required this.onReport,
    required this.onRate,
    required this.onTrack,
  });

  final Order order;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onViewDetails;
  final VoidCallback onReport;
  final VoidCallback onRate;
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final statusIcon = _statusIcon(
      order.status,
      isSellerConfirmed: order.isSellerConfirmed,
    );
    final statusLabel = buyerOrderStatusLabel(
      order.status,
      isSellerConfirmed: order.isSellerConfirmed,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: ColoredBox(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        statusIcon,
                        size: 17,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.ordersOrderNumberLabel(order.displayNumber),
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            order.dateLabel,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OrderStatusBadge(label: statusLabel, dense: true),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: order.imageUrl == null
                              ? Icon(
                                  order.icon,
                                  color: colorScheme.primary,
                                  size: 24,
                                )
                              : Image.network(
                                  order.imageUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) =>
                                      progress == null
                                      ? child
                                      : Icon(
                                          order.icon,
                                          color: colorScheme.primary,
                                          size: 24,
                                        ),
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        order.icon,
                                        color: colorScheme.primary,
                                        size: 24,
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
                                  fontWeight: FontWeight.w700,
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
                        Text(
                          formatPrice(ref, order.totalAmount),
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _PrimaryActionButton(
                            label: l10n.ordersViewDetailsButton,
                            onTap: onViewDetails,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                        ),
                        if (order.canReportProblem) ...[
                          const SizedBox(width: 10),
                          _SecondaryActionButton(
                            icon: Icons.flag_outlined,
                            label: l10n.ordersReportButton,
                            onTap: onReport,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                        ],
                      ],
                    ),
                    if (order.status == OrderStatus.released) ...[
                      const SizedBox(height: 10),
                      order.review != null
                          ? _SecondaryActionButton(
                              icon: Icons.star_rounded,
                              label: l10n.ordersAlreadyReviewedLabel,
                              onTap: null,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                              expand: true,
                            )
                          : _SecondaryActionButton(
                              icon: Icons.star_outline_rounded,
                              label: l10n.ordersRateReviewButton,
                              onTap: onRate,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                              expand: true,
                              accent: true,
                            ),
                    ] else if (order.isActive) ...[
                      const SizedBox(height: 10),
                      _SecondaryActionButton(
                        icon: Icons.location_on_outlined,
                        label: l10n.ordersTrackOrderButton,
                        onTap: onTrack,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        expand: true,
                        accent: true,
                      ),
                    ],
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

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: colorScheme.onPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
    this.expand = false,
    this.accent = false,
  });

  final IconData icon;
  final String label;

  /// Null renders the button as a non-interactive, dimmed indicator.
  final VoidCallback? onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  /// Stretches to fill the row instead of hugging its content width.
  final bool expand;

  /// Uses the primary brand color instead of the neutral outline styling.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    final tintColor = disabled
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
        : accent
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: disabled
                  ? colorScheme.outline.withValues(alpha: 0.5)
                  : accent
                  ? colorScheme.primary
                  : colorScheme.outline,
            ),
          ),
          child: Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: tintColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: tintColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.ordersEmptyStateMessage,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
