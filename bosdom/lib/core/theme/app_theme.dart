import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

/// Maps the Bosdom brand palette onto a full M3 [ColorScheme] so stock
/// Material 3 components (FilledButton, TextField, Card, NavigationBar...)
/// pick up brand colors with no per-widget styling.
abstract final class AppTheme {
  static const _colorScheme = ColorScheme(
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

  /// Shared shape/size for FilledButton, OutlinedButton, and TextButton so
  /// every primary/secondary action across the app renders at the same,
  /// easy-to-tap size instead of each screen hand-rolling its own.
  static final _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  );
  static const _buttonPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
  );
  static const _buttonMinimumSize = Size(64, 48);

  /// Applied to FilledButton/ElevatedButton when disabled so a pending CTA
  /// (e.g. "Continue" before a required upload/checkbox) still reads as an
  /// on-brand muted button instead of Material's near-invisible default
  /// (12%-opacity black), which looked like a stray pale box on screen.
  static final _disabledBackgroundColor = _colorScheme.primary.withValues(
    alpha: 0.35,
  );
  static final _disabledForegroundColor = _colorScheme.onPrimary.withValues(
    alpha: 0.85,
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: _colorScheme.surface,
      textTheme: AppTextTheme.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: _colorScheme.primary,
        foregroundColor: _colorScheme.onPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: _buttonMinimumSize,
          padding: _buttonPadding,
          shape: _buttonShape,
          textStyle: AppTextTheme.textTheme.labelLarge,
          disabledBackgroundColor: _disabledBackgroundColor,
          disabledForegroundColor: _disabledForegroundColor,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: _buttonMinimumSize,
          padding: _buttonPadding,
          shape: _buttonShape,
          textStyle: AppTextTheme.textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: _buttonMinimumSize,
          padding: _buttonPadding,
          shape: _buttonShape,
          textStyle: AppTextTheme.textTheme.labelLarge,
          disabledBackgroundColor: _disabledBackgroundColor,
          disabledForegroundColor: _disabledForegroundColor,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: _buttonMinimumSize,
          padding: _buttonPadding,
          shape: _buttonShape,
          textStyle: AppTextTheme.textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: _colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: _colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: _colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
