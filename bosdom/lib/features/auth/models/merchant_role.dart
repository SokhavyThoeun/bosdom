import 'package:flutter/material.dart';

/// The two ways a merchant can join Bosdom, driving the signup wizard's
/// step count and per-step field/option differences (retailer gets a
/// Google shortcut, supplier's extra KYC step does not).
enum MerchantRole {
  retailer(
    title: 'Retailer / Buyer',
    subtitle:
        'Shop owner, live-stream merchant, or kiosk. Browse and purchase '
        'wholesale goods.',
    icon: Icons.shopping_cart_outlined,
    totalSteps: 3,
  ),
  supplier(
    title: 'Wholesaler / Supplier',
    subtitle:
        'Distributor or manufacturer. List products and receive bulk orders.',
    icon: Icons.inventory_2_outlined,
    totalSteps: 4,
  );

  const MerchantRole({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.totalSteps,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final int totalSteps;
}
