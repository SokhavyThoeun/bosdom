import 'package:flutter/material.dart';

/// Standard content container using [CardTheme] with consistent padding
/// and an optional tap target for list-item-style cards.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: EdgeInsets.zero,
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;

    final theme = Theme.of(context).cardTheme;
    final shape = theme.shape;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: shape is RoundedRectangleBorder
            ? shape.borderRadius.resolve(Directionality.of(context))
            : null,
        child: card,
      ),
    );
  }
}
