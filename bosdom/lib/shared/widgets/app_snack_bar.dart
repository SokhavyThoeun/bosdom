import 'package:flutter/material.dart';

enum AppSnackBarType { success, info, error }

void showAppSnackBar(
  BuildContext context, {
  required String message,
  AppSnackBarType type = AppSnackBarType.success,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  final (Color background, IconData icon) = switch (type) {
    AppSnackBarType.success => (
      colorScheme.tertiary,
      Icons.check_circle_rounded,
    ),
    AppSnackBarType.info => (colorScheme.primary, Icons.info_rounded),
    AppSnackBarType.error => (colorScheme.error, Icons.error_rounded),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: background,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(icon, color: colorScheme.onPrimary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
