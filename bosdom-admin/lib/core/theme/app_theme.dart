import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Same brand mapping as the mobile app's `AppTheme`, but with a tighter,
/// denser shape language (12px radii, not 28px pills) — this is a
/// data-table-first admin dashboard, not a touch-first storefront.
abstract final class AppTheme {
  static const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.brandCrimson,
    onPrimary: AppColors.petalWhite,
    primaryContainer: AppColors.blushSurface,
    onPrimaryContainer: AppColors.deepBurgundy,
    secondary: AppColors.roseMist,
    onSecondary: AppColors.warmBlack,
    secondaryContainer: AppColors.blushSurface,
    onSecondaryContainer: AppColors.deepBurgundy,
    tertiary: AppColors.trustGreen,
    onTertiary: AppColors.petalWhite,
    error: AppColors.alertAmber,
    onError: AppColors.petalWhite,
    surface: AppColors.petalWhite,
    onSurface: AppColors.warmBlack,
    surfaceContainerHighest: AppColors.blushSurface,
    onSurfaceVariant: AppColors.warmTaupe,
    outline: AppColors.roseDivider,
    outlineVariant: AppColors.roseDivider,
    inverseSurface: AppColors.deepBurgundy,
    onInverseSurface: AppColors.petalWhite,
    inversePrimary: AppColors.roseMist,
  );

  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8F5F5),
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.45)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: _shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 44),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: _shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 40),
          shape: _shape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.6),
        space: 1,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(
          AppColors.blushSurface.withValues(alpha: 0.5),
        ),
        headingTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
          letterSpacing: 0.3,
        ),
        dataTextStyle: TextStyle(color: colorScheme.onSurface, fontSize: 13.5),
        dividerThickness: 1,
      ),
    );
  }
}
