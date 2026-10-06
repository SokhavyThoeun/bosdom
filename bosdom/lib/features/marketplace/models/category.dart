import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class Category {
  const Category(this.label, this.icon, this.iconAsset);
  final String label;
  final IconData icon;
  final String iconAsset;
}

/// Translated name to show for a category. [label] stays English because
/// it's the value stored on listings/deals in the backend.
String categoryDisplayName(AppLocalizations l10n, String label) =>
    switch (label) {
      'Electronics' => l10n.categoryElectronics,
      'Clothing' => l10n.categoryClothing,
      'Food & Bev' => l10n.categoryFoodBev,
      'Beauty' => l10n.categoryBeauty,
      'Home' => l10n.categoryHome,
      _ => label,
    };

const kCategories = [
  Category(
    'Electronics',
    Icons.devices_other_rounded,
    'assets/icons/categories/electronics.svg',
  ),
  Category(
    'Clothing',
    Icons.checkroom_rounded,
    'assets/icons/categories/clothing.svg',
  ),
  Category(
    'Food & Bev',
    Icons.restaurant_rounded,
    'assets/icons/categories/food_bev.svg',
  ),
  Category('Beauty', Icons.spa_rounded, 'assets/icons/categories/beauty.svg'),
  Category('Home', Icons.chair_rounded, 'assets/icons/categories/home.svg'),
];
