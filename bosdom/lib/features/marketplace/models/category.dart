import 'package:flutter/material.dart';

class Category {
  const Category(this.label, this.icon, this.iconAsset);
  final String label;
  final IconData icon;
  final String iconAsset;
}

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
