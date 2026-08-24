import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/co_buy_session.dart';

class CoBuyNotifier extends Notifier<List<CoBuySession>> {
  @override
  List<CoBuySession> build() => [
    CoBuySession(
      id: 'rice-50kg',
      icon: Icons.grass_rounded,
      productName: 'Jasmine Rice Premium 50kg Bulk Bag',
      sellerName: 'Mekong Harvest Wholesaler',
      sellerRating: 4.9,
      sellerLocation: 'Phnom Penh, Cambodia',
      sellerVerified: true,
      currentQty: 340,
      targetQty: 500,
      unitLabel: 'kg',
      perUnitLabel: 'per bag (50kg)',
      minOrderQty: 20,
      retailersJoined: 6,
      timeLeft: '2 days left',
      originalPrice: 45.00,
      price: 38.50,
      joined: true,
    ),
    CoBuySession(
      id: 'coconut-oil-5l',
      icon: Icons.opacity_rounded,
      productName: 'Coconut Oil 5L',
      sellerName: 'Phnom Penh Agri-Trade',
      sellerRating: 4.7,
      sellerLocation: 'Phnom Penh, Cambodia',
      sellerVerified: true,
      currentQty: 8,
      targetQty: 15,
      unitLabel: 'units',
      perUnitLabel: 'per unit (5L)',
      minOrderQty: 2,
      retailersJoined: 3,
      timeLeft: '18 hours left',
      originalPrice: 24.00,
      price: 19.80,
      joined: false,
    ),
    CoBuySession(
      id: 'fish-sauce-12pack',
      icon: Icons.set_meal_rounded,
      productName: 'Fish Sauce 12-pack',
      sellerName: 'Battambang Food Co.',
      sellerRating: 4.6,
      sellerLocation: 'Battambang, Cambodia',
      sellerVerified: false,
      currentQty: 30,
      targetQty: 30,
      unitLabel: 'packs',
      perUnitLabel: 'per pack (12ct)',
      minOrderQty: 4,
      retailersJoined: 9,
      timeLeft: 'Target reached',
      originalPrice: 18.50,
      price: 14.20,
      joined: true,
    ),
    CoBuySession(
      id: 'palm-sugar-10kg',
      icon: Icons.icecream_rounded,
      productName: 'Palm Sugar 10kg Bulk Pack',
      sellerName: 'Kampong Speu Palm Farms',
      sellerRating: 4.8,
      sellerLocation: 'Kampong Speu, Cambodia',
      sellerVerified: true,
      currentQty: 25,
      targetQty: 25,
      unitLabel: 'bags',
      perUnitLabel: 'per bag (10kg)',
      minOrderQty: 5,
      retailersJoined: 8,
      timeLeft: 'Target reached',
      originalPrice: 32.00,
      price: 26.50,
      joined: false,
    ),
  ];

  CoBuySession byId(String id) => state.firstWhere((s) => s.id == id);

  void toggleJoin(String id) {
    final session = state.firstWhere((s) => s.id == id);
    if (session.joined) {
      session.joined = false;
      session.currentQty = (session.currentQty - 1).clamp(0, session.targetQty);
      session.retailersJoined = (session.retailersJoined - 1).clamp(0, 9999);
    } else {
      if (session.isFull) return;
      session.joined = true;
      session.currentQty = (session.currentQty + 1).clamp(0, session.targetQty);
      session.retailersJoined += 1;
    }
    state = [...state];
  }
}

final coBuyProvider = NotifierProvider<CoBuyNotifier, List<CoBuySession>>(
  CoBuyNotifier.new,
);
