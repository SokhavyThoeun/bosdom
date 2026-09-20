import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/currency_format.dart';

/// A prominent price: the selected-currency amount, plus a smaller "≈ ..."
/// line in the other currency when the user has "show both currencies" on.
/// For dense list/card rows, use [formatPrice] directly instead — this is
/// for the one or two standout totals per screen (order total, product
/// price, amount to pay).
class PriceDisplay extends ConsumerWidget {
  const PriceDisplay(
    this.amountUsd, {
    super.key,
    required this.style,
    this.secondaryStyle,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final double amountUsd;
  final TextStyle? style;
  final TextStyle? secondaryStyle;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primary = formatPrice(ref, amountUsd);
    final secondary = formatSecondaryPrice(ref, amountUsd);
    if (secondary == null) {
      return Text(primary, style: style);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(primary, style: style),
        Text(
          secondary,
          style:
              secondaryStyle ??
              style?.copyWith(
                fontSize: (style?.fontSize ?? 14) * 0.72,
                fontWeight: FontWeight.w500,
                color: style?.color?.withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}
