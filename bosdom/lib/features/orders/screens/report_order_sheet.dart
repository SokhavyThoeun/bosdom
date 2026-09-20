import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../services/report_service.dart';

enum _ReportReason { wrongItem, damaged, missing, lateDelivery, other }

extension on _ReportReason {
  String label(AppLocalizations l10n) => switch (this) {
    _ReportReason.wrongItem => l10n.ordersReportReasonWrongItem,
    _ReportReason.damaged => l10n.ordersReportReasonDamaged,
    _ReportReason.missing => l10n.ordersReportReasonMissing,
    _ReportReason.lateDelivery => l10n.ordersReportReasonLateDelivery,
    _ReportReason.other => l10n.ordersReportReasonOther,
  };

  // Stable key sent to the backend, independent of the localized label.
  String get apiValue => switch (this) {
    _ReportReason.wrongItem => 'wrong_item',
    _ReportReason.damaged => 'damaged',
    _ReportReason.missing => 'missing',
    _ReportReason.lateDelivery => 'late_delivery',
    _ReportReason.other => 'other',
  };
}

/// Opens the "Report Order" bottom sheet for [order]. Resolves once the
/// sheet is dismissed.
Future<void> showReportOrderSheet(BuildContext context, Order order) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _ReportOrderSheet(order: order),
  );
}

class _ReportOrderSheet extends ConsumerStatefulWidget {
  const _ReportOrderSheet({required this.order});

  final Order order;

  @override
  ConsumerState<_ReportOrderSheet> createState() => _ReportOrderSheetState();
}

class _ReportOrderSheetState extends ConsumerState<_ReportOrderSheet> {
  _ReportReason _reason = _ReportReason.wrongItem;
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSubmitting = true);
    try {
      await ReportService.reportOrder(
        orderId: widget.order.id,
        reason: _reason.apiValue,
        note: _noteController.text.trim(),
      );
      ref.invalidate(orderByIdProvider(widget.order.id));
      ref.invalidate(ordersProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnackBar(
        context,
        message: l10n.escrowReportSubmittedFrozen,
        type: AppSnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showAppSnackBar(
        context,
        message: l10n.ordersReportFailedSnackbar('$e'),
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
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
                        l10n.ordersReportSheetTitle,
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.ordersReportReasonLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final reason in _ReportReason.values)
                      ChoiceChip(
                        label: Text(reason.label(l10n)),
                        selected: _reason == reason,
                        onSelected: (_) => setState(() => _reason = reason),
                        labelStyle: textTheme.labelMedium?.copyWith(
                          color: _reason == reason
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        selectedColor: colorScheme.primary,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide.none,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.ordersReportNoteLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.ordersReportNoteHint,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.ordersReportSubmitButton),
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
