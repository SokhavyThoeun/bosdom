import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextTheme {
  static TextTheme get textTheme => const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.warmBlack,
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: AppColors.warmBlack,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.warmBlack,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.warmBlack,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.warmBlack,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.warmBlack,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.warmBlack),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.warmBlack),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.warmTaupe),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.warmBlack,
    ),
    labelMedium: TextStyle(fontSize: 12, color: AppColors.warmTaupe),
    labelSmall: TextStyle(fontSize: 11, color: AppColors.warmTaupe),
  );
}
