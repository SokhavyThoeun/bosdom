import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/hourglass_icon.dart';
import '../../../shared/widgets/price_display.dart';
import '../../marketplace/widgets/empty_products_notice.dart';
import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import '../../orders/services/order_service.dart';
import '../models/earnings.dart';
import 'success_dialog.dart';
import 'withdraw_funds_sheet.dart';

// Same header size/shape as the other seller screens so moving between
// the dashboard, orders, and earnings feels like the same app.
const _kHeaderContentHeight = 68.0;

const _kFilters = [
  null,
  EarningsStatus.released,
  EarningsStatus.inEscrow,
  EarningsStatus.disputed,
];

class SellerEarningsScreen extends ConsumerStatefulWidget {
  const SellerEarningsScreen({super.key});

  @override
  ConsumerState<SellerEarningsScreen> createState() =>
      _SellerEarningsScreenState();
}

class _SellerEarningsScreenState extends ConsumerState<SellerEarningsScreen> {
  EarningsStatus? _filter;
  bool _isRequestingRelease = false;

  bool _matchesFilter(EarningsTransaction transaction) => switch (_filter) {
    null => true,
    EarningsStatus.inEscrow => transaction.isHeld,
    final status => transaction.status == status,
  };

  /// Withdraws the whole released balance (money from orders the buyer has
  /// already received) to a bank account the seller fills in first. The
  /// transfer lands 1 to 3 hours later.
  Future<void> _requestRelease(EarningsSummary summary) async {
    final l10n = AppLocalizations.of(context);
    if (summary.availableBalance <= 0) {
      showAppSnackBar(
        context,
        message: l10n.sellerEarningsPayoutNothingMessage,
        type: AppSnackBarType.error,
      );
      return;
    }

    final bank = await showWithdrawFundsSheet(
      context,
      balanceLabel: formatPrice(ref, summary.availableBalance),
    );
    if (bank == null || !mounted) return;

    setState(() => _isRequestingRelease = true);
    try {
      final payout = await OrderService.requestPayout(
        bankName: bank.bankName,
        accountHolder: bank.accountHolder,
        accountNumber: bank.accountNumber,
      );
      ref.invalidate(sellerOrdersProvider);
      if (!mounted) return;
      setState(() => _isRequestingRelease = false);
      await showSuccessDialog(
        context,
        title: l10n.sellerEarningsWithdrawSuccessTitle,
        message: l10n.sellerEarningsPayoutSuccessMessage(
          formatPrice(ref, payout),
        ),
        buttonLabel: l10n.sellerEarningsWithdrawSuccessOkButton,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isRequestingRelease = false);
      showAppSnackBar(
        context,
        message: l10n.sellerEarningsPayoutFailedSnackbar('$e'),
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final ordersAsync = ref.watch(sellerOrdersProvider);

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
                    onRetry: () =>
                        ref.read(sellerOrdersProvider.notifier).refresh(),
                  ),
                ),
                data: (orders) => _buildContent(context, orders),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Order> orders) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final summary = EarningsSummary([
      for (final order in orders) ?EarningsTransaction.fromOrder(order),
    ]);
    final filtered = summary.transactions.where(_matchesFilter).toList();
    final filteredTotal = filtered.fold<double>(
      0,
      (sum, transaction) => sum + transaction.netAmount,
    );

    return RefreshIndicator(
      onRefresh: () => ref.read(sellerOrdersProvider.notifier).refresh(),
      color: colorScheme.primary,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          _BalanceCard(
            availableBalance: summary.availableBalance,
            completedSalesPercent: summary.completedSalesPercent,
            isBusy: _isRequestingRelease,
            onWithdraw: () => _requestRelease(summary),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          _StatsRow(
            releasedTotal: summary.releasedTotal,
            inEscrowTotal: summary.inEscrowTotal,
            refundedTotal: summary.refundedTotal,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          _FilterRow(
            selected: _filter,
            onSelected: (status) => setState(() => _filter = status),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.sellerEarningsTransactionsCountLabel(filtered.length),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatPrice(ref, filteredTotal),
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            _EmptyState(colorScheme: colorScheme, textTheme: textTheme)
          else
            for (var i = 0; i < filtered.length; i++) ...[
              _TransactionCard(
                transaction: filtered[i],
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              if (i != filtered.length - 1) const SizedBox(height: 12),
            ],
          const SizedBox(height: 16),
          _EscrowNotice(colorScheme: colorScheme, textTheme: textTheme),
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
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.goNamed('sellerDashboard'),
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
                l10n.sellerEarningsScreenTitle,
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

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard({
    required this.availableBalance,
    required this.completedSalesPercent,
    required this.isBusy,
    required this.onWithdraw,
    required this.colorScheme,
    required this.textTheme,
  });

  final double availableBalance;
  final int completedSalesPercent;
  final bool isBusy;
  final VoidCallback onWithdraw;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            l10n.sellerEarningsAvailableBalanceLabel,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          PriceDisplay(
            availableBalance,
            crossAxisAlignment: CrossAxisAlignment.center,
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.brandCrimson,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.sellerEarningsCompletedSalesPercentLabel(
              completedSalesPercent,
            ),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandCrimson,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: isBusy ? null : onWithdraw,
              child: Text(
                l10n.sellerEarningsWithdrawButton,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatefulWidget {
  const _StatsRow({
    required this.releasedTotal,
    required this.inEscrowTotal,
    required this.refundedTotal,
    required this.colorScheme,
    required this.textTheme,
  });

  final double releasedTotal;
  final double inEscrowTotal;
  final double refundedTotal;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  State<_StatsRow> createState() => _StatsRowState();
}

class _StatsRowState extends State<_StatsRow>
    with SingleTickerProviderStateMixin {
  // One controller drives all three tiles; each gets a later, overlapping
  // slice of it so they cascade in left to right.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  Animation<double> _slice(int index) => CurvedAnimation(
    parent: _controller,
    curve: Interval(
      index * 0.14,
      0.58 + index * 0.14,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = widget.colorScheme;
    final textTheme = widget.textTheme;
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            animation: _slice(0),
            icon: const Icon(Icons.check_circle_rounded, size: 20),
            label: l10n.sellerEarningsReleasedLabel,
            amount: widget.releasedTotal,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            animation: _slice(1),
            icon: HourglassIcon(size: 20, color: colorScheme.primary),
            label: l10n.sellerEarningsInEscrowLabel,
            amount: widget.inEscrowTotal,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            animation: _slice(2),
            icon: const Icon(Icons.undo_rounded, size: 20),
            label: l10n.sellerEarningsRefundedLabel,
            amount: widget.refundedTotal,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends ConsumerStatefulWidget {
  const _StatTile({
    required this.animation,
    required this.icon,
    required this.label,
    required this.amount,
    required this.colorScheme,
    required this.textTheme,
  });

  final Animation<double> animation;
  final Widget icon;
  final String label;
  final double amount;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  ConsumerState<_StatTile> createState() => _StatTileState();
}

class _StatTileState extends ConsumerState<_StatTile> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;
    final textTheme = widget.textTheme;
    final accent = colorScheme.primary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: widget.animation,
          builder: (context, child) {
            final t = widget.animation.value;
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - t)),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.outline),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: _pressed ? 0.02 : 0.07),
                  blurRadius: _pressed ? 6 : 14,
                  offset: Offset(0, _pressed ? 2 : 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Icon badge springs in slightly after the card lands.
                AnimatedBuilder(
                  animation: widget.animation,
                  builder: (context, child) {
                    final pop = Curves.elasticOut.transform(
                      ((widget.animation.value - 0.3) / 0.7).clamp(0.0, 1.0),
                    );
                    return Transform.scale(scale: pop, child: child);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconTheme(
                      data: IconThemeData(color: accent),
                      child: widget.icon,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.label.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                // Amount counts up from zero as the tile settles in.
                AnimatedBuilder(
                  animation: widget.animation,
                  // Single line that shrinks to fit so big totals never wrap
                  // and all three tiles keep the same height.
                  builder: (context, _) => FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      formatPrice(ref, widget.amount * widget.animation.value),
                      maxLines: 1,
                      softWrap: false,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
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

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selected,
    required this.onSelected,
    required this.colorScheme,
    required this.textTheme,
  });

  final EarningsStatus? selected;
  final ValueChanged<EarningsStatus?> onSelected;
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
              label: switch (_kFilters[i]) {
                null => l10n.sellerEarningsFilterAllLabel,
                EarningsStatus.released =>
                  l10n.sellerEarningsFilterReleasedLabel,
                EarningsStatus.inEscrow =>
                  l10n.sellerEarningsFilterInEscrowLabel,
                EarningsStatus.disputed =>
                  l10n.sellerEarningsFilterDisputedLabel,
                _ => '',
              },
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

class _TransactionCard extends ConsumerWidget {
  const _TransactionCard({
    required this.transaction,
    required this.colorScheme,
    required this.textTheme,
  });

  final EarningsTransaction transaction;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final amountColor = colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.sellerEarningsOrderBuyerLabel(
                        transaction.displayNumber,
                        transaction.buyerName,
                      ),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.date,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${formatPrice(ref, transaction.netAmount)}',
                    style: textTheme.titleSmall?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _Badge(
                    label: earningsStatusLabel(l10n, transaction.status),
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
          ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            _SummaryRow(
              label: l10n.sellerEarningsSaleAmountLabel,
              value: transaction.saleAmount,
              textTheme: textTheme,
            ),
            const SizedBox(height: 4),
            _SummaryRow(
              label: l10n.sellerEarningsPlatformFeeLabel(
                (transaction.platformFeeRate * 100).round(),
              ),
              value: -transaction.platformFee,
              textTheme: textTheme,
            ),
            const SizedBox(height: 4),
            _SummaryRow(
              label: l10n.sellerEarningsYourEarningsLabel,
              value: transaction.netAmount,
              bold: true,
              textTheme: textTheme,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends ConsumerWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.textTheme,
    this.bold = false,
  });

  final String label;
  final double value;
  final bool bold;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final sign = value < 0 ? '-' : '';
    final style = bold
        ? textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
        : textTheme.bodyMedium;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: bold
              ? style
              : style?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Text('$sign${formatPrice(ref, value.abs())}', style: style),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EscrowNotice extends StatelessWidget {
  const _EscrowNotice({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blushSurface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.roseDivider),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.gpp_good_outlined,
              color: AppColors.brandCrimson,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.sellerEarningsEscrowNoticeText,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.brandCrimson,
                height: 1.4,
              ),
            ),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 48),
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
              l10n.sellerEarningsEmptyStateMessage,
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
