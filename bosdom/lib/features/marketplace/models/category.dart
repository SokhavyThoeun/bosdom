import 'package:flutter/material.dart';

class Category {
  const Category(this.label, this.icon);
  final String label;
  final IconData icon;
}

const kCategories = [
  Category('Electronics', Icons.devices_other_rounded),
  Category('Clothing', Icons.checkroom_rounded),
  Category('Food & Bev', Icons.restaurant_rounded),
  Category('Beauty', Icons.spa_rounded),
  Category('Home', Icons.chair_rounded),
];
