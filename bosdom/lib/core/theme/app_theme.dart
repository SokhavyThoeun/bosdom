import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_theme.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandCrimson,
      brightness: Brightness.light,
      primary: AppColors.brandCrimson,
      onPrimary: AppColors.petalWhite,
      secondary: AppColors.roseMist,
      onSecondary: AppColors.warmBlack,
      surface: AppColors.petalWhite,
      onSurface: AppColors.warmBlack,
      error: AppColors.alertAmber,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.petalWhite,
      textTheme: AppTextTheme.textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.brandCrimson,
        foregroundColor: AppColors.petalWhite,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.blushSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.roseDivider),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.roseDivider,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandCrimson,
          foregroundColor: AppColors.petalWhite,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.pressed)
                    ? AppColors.deepBurgundy
                    : null,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blushSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.deepBurgundy,
        contentTextStyle: TextStyle(color: AppColors.petalWhite),
      ),
    );
  }
}
