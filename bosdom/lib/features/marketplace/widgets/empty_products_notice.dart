import 'package:flutter/material.dart';

/// Shared empty/error placeholder for a product list backed by the
/// listings API — used for both "no products yet" and "failed to load"
/// states, distinguished by [onRetry] being set.
class EmptyProductsNotice extends StatelessWidget {
  const EmptyProductsNotice({
    super.key,
    required this.colorScheme,
    required this.textTheme,
    required this.message,
    this.onRetry,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onRetry,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              onRetry != null
                  ? Icons.cloud_off_outlined
                  : Icons.inventory_2_outlined,
              size: 40,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              message,
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
