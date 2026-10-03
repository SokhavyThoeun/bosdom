import 'package:flutter/material.dart';

/// Icon + stock text (e.g. "Available Stock: 340 Bags") whose text slides in
/// whenever [stock] changes, so buyers see the count move live as a polled
/// screen picks up other buyers' purchases.
class LiveStockRow extends StatelessWidget {
  const LiveStockRow({
    super.key,
    required this.stock,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  final int stock;

  /// The full text to show for [stock].
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.warehouse_outlined,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previous, ?current],
            ),
            child: Text(
              label,
              key: ValueKey(stock),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
