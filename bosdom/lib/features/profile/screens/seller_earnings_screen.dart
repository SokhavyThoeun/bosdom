import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/earnings.dart';
import 'success_dialog.dart';
import 'withdraw_funds_sheet.dart';

// Same header size/shape as the other seller screens so moving between
// the dashboard, orders, and earnings feels like the same app.
const _kHeaderContentHeight = 96.0;

const _kFilters = [
  null,
  EarningsStatus.released,
  EarningsStatus.inEscrow,
  EarningsStatus.disputed,
];

class SellerEarningsScreen extends StatefulWidget {
  const SellerEarningsScreen({super.key});

  @override
  State<SellerEarningsScreen> createState() => _SellerEarningsScreenState();
}

class _SellerEarningsScreenState extends State<SellerEarningsScreen> {
  EarningsStatus? _filter;
  late double _availableBalance = kMockAvailableBalance;
  late final List<EarningsTransaction> _transactions = List.of(
    kMockEarningsTransactions,
  );

  List<EarningsTransaction> _filtered(List<EarningsTransaction> all) =>
      _filter == null
      ? all
      : all.where((transaction) => transaction.status == _filter).toList();

  Future<void> _withdraw() async {
    final l10n = AppLocalizations.of(context);
    final result = await showWithdrawFundsSheet(
      context,
      availableBalance: _availableBalance,
    );
    if (result == null || !mounted) return;
    setState(() {
      _availableBalance -= result.amount;
      _transactions.insert(
        0,
        EarningsTransaction.withdrawal(
          id: 'WD-${DateTime.now().millisecondsSinceEpoch}',
          date: l10n.sellerEarningsWithdrawJustNowLabel,
          amount: result.amount,
          withdrawalMethod: result.methodLabel,
        ),
      );
    });
    if (!mounted) return;
    await showSuccessDialog(
      context,
      title: l10n.sellerEarningsWithdrawSuccessTitle,
      message: l10n.sellerEarningsWithdrawSuccessMessage(
        '\$${result.amount.toStringAsFixed(2)}',
      ),
      buttonLabel: l10n.sellerEarningsWithdrawSuccessOkButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final filtered = _filtered(_transactions);
    final filteredTotal = filtered.fold<double>(
      0,
      (sum, transaction) => sum + transaction.signedAmount,
    );

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
                  24,
                  20,
                  24,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  _BalanceCard(
                    availableBalance: _availableBalance,
                    onWithdraw: _withdraw,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 16),
                  _StatsRow(colorScheme: colorScheme, textTheme: textTheme),
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
                        l10n.sellerEarningsTransactionsCountLabel(
                          filtered.length,
                        ),
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${filteredTotal.abs().toStringAsFixed(2)}',
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

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.availableBalance,
    required this.onWithdraw,
    required this.colorScheme,
    required this.textTheme,
  });

  final double availableBalance;
  final VoidCallback onWithdraw;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
          Text(
            '\$${availableBalance.toStringAsFixed(2)}',
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.brandCrimson,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.sellerEarningsCompletedSalesPercentLabel(
              kMockCompletedSalesPercent,
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
              onPressed: onWithdraw,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.check_circle_rounded,
            label: l10n.sellerEarningsReleasedLabel,
            amount: kMockReleasedTotal,
            accentColor: colorScheme.primary,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.hourglass_top_rounded,
            label: l10n.sellerEarningsInEscrowLabel,
            amount: kMockInEscrowTotal,
            accentColor: colorScheme.primary,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            icon: Icons.undo_rounded,
            label: l10n.sellerEarningsRefundedLabel,
            amount: kMockRefundedTotal,
            accentColor: colorScheme.primary,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.accentColor,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final double amount;
  final Color accentColor;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
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

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.transaction,
    required this.colorScheme,
    required this.textTheme,
  });

  final EarningsTransaction transaction;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final positive = transaction.signedAmount >= 0;
    final amountColor = positive ? AppColors.trustGreen : colorScheme.onSurface;

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
                      transaction.isWithdrawal
                          ? l10n.sellerEarningsWithdrawalLabel
                          : l10n.sellerEarningsOrderBuyerLabel(
                              transaction.id,
                              transaction.buyerName!,
                            ),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.isWithdrawal
                          ? transaction.withdrawalMethod!
                          : transaction.date,
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
                    '${positive ? '+' : '-'}\$${transaction.signedAmount.abs().toStringAsFixed(2)}',
                    style: textTheme.titleSmall?.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _Badge(
                    label: earningsStatusLabel(l10n, transaction.status),
                    color: earningsStatusColor(transaction.status),
                  ),
                ],
              ),
            ],
          ),
          if (transaction.isWithdrawal) ...[
            const SizedBox(height: 8),
            Text(
              transaction.date,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ] else ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            _SummaryRow(
              label: l10n.sellerEarningsSaleAmountLabel,
              value: transaction.saleAmount!,
              textTheme: textTheme,
            ),
            const SizedBox(height: 4),
            _SummaryRow(
              label: l10n.sellerEarningsPlatformFeeLabel(
                (transaction.platformFeeRate * 100).round(),
              ),
              value: -transaction.platformFee,
              valueColor: AppColors.brandCrimson,
              textTheme: textTheme,
            ),
            const SizedBox(height: 4),
            _SummaryRow(
              label: l10n.sellerEarningsYourEarningsLabel,
              value: transaction.signedAmount,
              bold: true,
              textTheme: textTheme,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.textTheme,
    this.valueColor,
    this.bold = false,
  });

  final String label;
  final double value;
  final Color? valueColor;
  final bool bold;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
        Text(
          '$sign\$${value.abs().toStringAsFixed(2)}',
          style: style?.copyWith(color: valueColor),
        ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.infoBlue.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.infoBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.sellerEarningsEscrowNoticeText,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.infoBlue,
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
