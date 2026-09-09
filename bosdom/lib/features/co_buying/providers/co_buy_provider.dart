import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/variant_option.dart';
import '../models/co_buy_session.dart';

class CoBuyNotifier extends Notifier<List<CoBuySession>> {
  @override
  List<CoBuySession> build() => [
    CoBuySession(
      id: 'rice-50kg',
      icon: Icons.grass_rounded,
      imageQuery: 'rice,sack',
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
      imageQuery: 'coconut,oil',
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
      imageQuery: 'fish,sauce',
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
      imageQuery: 'palm,sugar',
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
    CoBuySession(
      id: 'tshirt-bulk',
      icon: Icons.checkroom_rounded,
      imageQuery: 'tshirt,stack',
      productName: 'Wholesale Cotton T-Shirts (Pack of 12)',
      sellerName: 'Apparel Hub',
      sellerRating: 4.6,
      sellerLocation: 'Phnom Penh, Cambodia',
      sellerVerified: true,
      currentQty: 18,
      targetQty: 40,
      unitLabel: 'packs',
      perUnitLabel: 'per pack (12ct)',
      minOrderQty: 2,
      retailersJoined: 5,
      timeLeft: '3 days left',
      originalPrice: 36.00,
      price: 29.90,
      joined: false,
      sizes: const ['S', 'M', 'L', 'XL', 'XXL'],
      colorOptions: const [
        ProductColorOption('White', Color(0xFFFFFFFF)),
        ProductColorOption('Black', Color(0xFF1A1A1A)),
        ProductColorOption('Navy', Color(0xFF243B55)),
        ProductColorOption('Red', Color(0xFFB3261E)),
      ],
    ),
  ];

  CoBuySession byId(String id) => state.firstWhere((s) => s.id == id);

  /// Creates a new co-buy session started by the current user, who is
  /// automatically counted as its first joined member.
  CoBuySession create({
    required String productName,
    required String imageQuery,
    required IconData icon,
    required String sellerName,
    required double sellerRating,
    required String sellerLocation,
    required bool sellerVerified,
    required int targetQty,
    required String unitLabel,
    required String perUnitLabel,
    required int minOrderQty,
    required String timeLeft,
    required double originalPrice,
    required double price,
    String description = '',
    bool autoRenew = false,
    List<String> imagePaths = const [],
  }) {
    final session = CoBuySession(
      id: '${_slugify(productName)}-${DateTime.now().millisecondsSinceEpoch}',
      icon: icon,
      imageQuery: imageQuery,
      productName: productName,
      description: description,
      sellerName: sellerName,
      sellerRating: sellerRating,
      sellerLocation: sellerLocation,
      sellerVerified: sellerVerified,
      currentQty: 1,
      targetQty: targetQty,
      unitLabel: unitLabel,
      perUnitLabel: perUnitLabel,
      minOrderQty: minOrderQty,
      retailersJoined: 1,
      timeLeft: timeLeft,
      originalPrice: originalPrice,
      price: price,
      joined: true,
      autoRenew: autoRenew,
      imagePaths: imagePaths,
    );
    state = [session, ...state];
    return session;
  }

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

  /// Updates the editable fields of an existing deal, leaving join progress
  /// and seller identity untouched.
  void update(
    String id, {
    required String productName,
    required int targetQty,
    required String unitLabel,
    required String perUnitLabel,
    required int minOrderQty,
    required String timeLeft,
    required double originalPrice,
    required double price,
    String description = '',
    bool autoRenew = false,
    List<String>? imagePaths,
  }) {
    state = [
      for (final s in state)
        if (s.id == id)
          CoBuySession(
            id: s.id,
            icon: s.icon,
            imageQuery: s.imageQuery,
            productName: productName,
            description: description,
            sellerName: s.sellerName,
            sellerRating: s.sellerRating,
            sellerLocation: s.sellerLocation,
            sellerVerified: s.sellerVerified,
            currentQty: s.currentQty,
            targetQty: targetQty,
            unitLabel: unitLabel,
            perUnitLabel: perUnitLabel,
            minOrderQty: minOrderQty,
            retailersJoined: s.retailersJoined,
            timeLeft: timeLeft,
            originalPrice: originalPrice,
            price: price,
            joined: s.joined,
            autoRenew: autoRenew,
            imagePaths: imagePaths ?? s.imagePaths,
            sizes: s.sizes,
            colorOptions: s.colorOptions,
          )
        else
          s,
    ];
  }

  void delete(String id) {
    state = state.where((s) => s.id != id).toList();
  }
}

final coBuyProvider = NotifierProvider<CoBuyNotifier, List<CoBuySession>>(
  CoBuyNotifier.new,
);

String _slugify(String input) => input
    .toLowerCase()
    .trim()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');
