import 'package:flutter/material.dart';

class CoBuySession {
  CoBuySession({
    required this.id,
    required this.icon,
    required this.productName,
    required this.sellerName,
    required this.sellerRating,
    required this.sellerLocation,
    required this.sellerVerified,
    required this.currentQty,
    required this.targetQty,
    required this.unitLabel,
    required this.perUnitLabel,
    required this.minOrderQty,
    required this.retailersJoined,
    required this.timeLeft,
    required this.originalPrice,
    required this.price,
    required this.joined,
  });

  final String id;
  final IconData icon;
  final String productName;
  final String sellerName;
  final double sellerRating;
  final String sellerLocation;
  final bool sellerVerified;
  final int targetQty;
  final String unitLabel;
  final String perUnitLabel;
  final int minOrderQty;
  final String timeLeft;
  final double originalPrice;
  final double price;

  int currentQty;
  int retailersJoined;
  bool joined;

  double get progress => currentQty / targetQty;
  int get remainingQty => targetQty - currentQty;
  bool get isFull => currentQty >= targetQty;
  int get savingsPct =>
      (((originalPrice - price) / originalPrice) * 100).round();
}
