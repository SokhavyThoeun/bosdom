import 'package:flutter/material.dart';

/// A single consistent pill for showing an order/delivery status label —
/// used by every buyer and seller order screen so a status always reads the
/// same way (one theme color, centered text, no per-status color coding).
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.label, this.dense = false});

  final String label;

  /// Tighter padding/smaller text for list rows, where the badge sits
  /// alongside other compact content.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 10 : 12,
        vertical: dense ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: (dense ? textTheme.labelSmall : textTheme.labelMedium)?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
