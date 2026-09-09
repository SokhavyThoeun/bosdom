import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/services/shipping_fee_calculator.dart';
import '../../../shared/utils/mock_images.dart';

/// A seller-side order lifecycle — distinct from the buyer-facing
/// [OrderStatus] in `features/orders/models/order.dart`, which tracks the
/// same purchase from the other side (processing/shipped/delivered).
enum SellerOrderStatus {
  pending,
  processing,
  shipped,
  completed;

  String get label => switch (this) {
    SellerOrderStatus.pending => 'Pending',
    SellerOrderStatus.processing => 'Processing',
    SellerOrderStatus.shipped => 'Shipped',
    SellerOrderStatus.completed => 'Completed',
  };
}

/// Status badge color, shared by the seller dashboard's recent-orders
/// preview and the full seller orders list so the same status always reads
/// the same color across both screens.
Color sellerOrderStatusColor(SellerOrderStatus status) => switch (status) {
  SellerOrderStatus.pending => AppColors.alertAmber,
  SellerOrderStatus.processing => AppColors.infoBlue,
  SellerOrderStatus.shipped => AppColors.trustGreen,
  SellerOrderStatus.completed => AppColors.trustGreen,
};

/// Platform commission taken out of every order's subtotal before it's paid
/// out to the seller — shown as the "Platform Fee" line on the seller order
/// detail screen.
const kSellerPlatformFeeRate = 0.10;

/// Every seller in this dataset ships from Phnom Penh — matches
/// [Product.location]'s default in `features/marketplace/models/product.dart`,
/// which is where a seller's listings say they ship from.
const kSellerOriginProvince = 'Phnom Penh';

/// Cambodian provinces this dataset's buyer addresses use. Real buyer
/// addresses here are free-text strings (no structured province field), so
/// this does a best-effort substring match to find which one a shipment is
/// headed to — good enough to pick the right shipping-fee bracket without
/// re-modelling the address as structured fields.
const _kKnownProvinces = ['Phnom Penh', 'Battambang', 'Siem Reap'];

String _provinceFromAddress(String address) => _kKnownProvinces.firstWhere(
  (province) => address.contains(province),
  orElse: () => kSellerOriginProvince,
);

class SellerOrder {
  const SellerOrder({
    required this.id,
    required this.date,
    required this.status,
    required this.buyerName,
    required this.buyerAddress,
    required this.buyerPhone,
    required this.quantityLabel,
    required this.quantity,
    required this.productName,
    required this.unitPrice,
    required this.unitWeightKg,
    required this.total,
    required this.imageQuery,
    this.deliveryMethod = kVireakBunthamCarrier,
    this.icon = Icons.inventory_2_outlined,
    this.isCoBuy = false,
  });

  final String id;
  final String date;
  final SellerOrderStatus status;
  final String buyerName;
  final String buyerAddress;
  final String buyerPhone;

  /// e.g. "150 bags" — paired with [productName] as "150 bags • Kampot Pepper".
  final String quantityLabel;

  /// Same count as [quantityLabel], as a number — used to compute the
  /// shipment's total weight for the shipping-fee estimate.
  final int quantity;
  final String productName;

  /// Price per unit, e.g. 12.50 for "150 Bags × $12.50".
  final double unitPrice;

  /// Weight per unit in kg, e.g. 0.5 for a 500g bag — multiplied by
  /// [quantity] to get the shipment's total weight for the carrier's
  /// weight-based pricing tiers.
  final double unitWeightKg;
  final double total;
  final String imageQuery;

  /// Carrier the buyer picked at checkout — matches the delivery method
  /// options and logos used on the buyer-side order detail screen so the
  /// same method always renders the same way.
  final String deliveryMethod;
  final IconData icon;
  final bool isCoBuy;

  String get imageUrl => mockPhotoUrl(imageQuery, id);

  double get platformFee => total * kSellerPlatformFeeRate;

  double get totalWeightKg => unitWeightKg * quantity;

  /// The real carrier pricing model (see [estimateShippingFee]) applied to
  /// this shipment's actual weight and route. `null` only if the buyer's
  /// checkout somehow let through a carrier that can't serve this
  /// weight/route — shouldn't happen since checkout only offers carriers
  /// that already pass this same check.
  ShippingQuote? get shippingQuote => estimateShippingFee(
    carrier: deliveryMethod,
    weightKg: totalWeightKg,
    originProvince: kSellerOriginProvince,
    destinationProvince: _provinceFromAddress(buyerAddress),
  );

  /// What the buyer paid for shipping at checkout. The seller is the one
  /// who actually pays the courier (e.g. dropping the package off at a VET
  /// counter and paying there), so this amount is reimbursed to the seller
  /// on top of their product earnings rather than being kept by the buyer
  /// or the platform.
  double get shippingFee => shippingQuote?.fee ?? 0;

  String get shippingFeeLabel => shippingFee == 0
      ? 'Free'
      : '+\$${shippingFee.toStringAsFixed(2)} (Reimbursed)';

  double get earnings => total - platformFee + shippingFee;
}

final kMockSellerOrders = [
  SellerOrder(
    id: 'BD-98402',
    date: 'Oct 28, 2025',
    status: SellerOrderStatus.pending,
    buyerName: 'Sokhavy Thoeun',
    buyerAddress:
        'Building 42B, Street 271, Sangkat Toeuk Thla, Khan Sen Sok, '
        'Phnom Penh, 120801, Cambodia',
    buyerPhone: '+855 12 345 678',
    quantityLabel: '150 bags',
    quantity: 150,
    productName: 'Kampot Pepper',
    unitPrice: 12.50,
    unitWeightKg: 0.5,
    total: 1875.00,
    imageQuery: 'black,pepper',
    icon: Icons.grain_outlined,
    deliveryMethod: kVireakBunthamCarrier,
  ),
  SellerOrder(
    id: 'BD-98399',
    date: 'Oct 26, 2025',
    status: SellerOrderStatus.processing,
    buyerName: 'Vannak Khorn',
    buyerAddress: 'National Road 5, Sangkat Svay Por, Battambang, Cambodia',
    buyerPhone: '+855 77 654 321',
    quantityLabel: '500 bags',
    quantity: 500,
    productName: 'Jasmine Rice',
    unitPrice: 45.00,
    unitWeightKg: 1.0,
    total: 22500.00,
    imageQuery: 'jasmine,rice,bag',
    icon: Icons.rice_bowl_outlined,
    // 500kg to another province — J&T handles heavier cargo-style
    // shipments like this fine in Cambodia.
    deliveryMethod: kJtExpressCarrier,
  ),
  SellerOrder(
    id: 'BD-98390',
    date: 'Oct 25, 2025',
    status: SellerOrderStatus.shipped,
    buyerName: 'Phnom Penh Grocers',
    buyerAddress:
        'Street 271, Sangkat Boeung Tumpun, Khan Mean Chey, Phnom Penh, '
        'Cambodia',
    buyerPhone: '+855 92 456 789',
    quantityLabel: '200 boxes',
    quantity: 200,
    productName: 'Dried Mango',
    unitPrice: 15.40,
    unitWeightKg: 0.09,
    total: 3080.00,
    imageQuery: 'dried,mango',
    icon: Icons.local_shipping_outlined,
    // 18kg, Phnom Penh to Phnom Penh — within Grab Express's same-city,
    // <20kg range.
    deliveryMethod: kGrabExpressCarrier,
  ),
  SellerOrder(
    id: 'BD-98377',
    date: 'Oct 22, 2025',
    status: SellerOrderStatus.completed,
    buyerName: 'Mekong Agri Trade',
    buyerAddress: 'Wat Bo Road, Sangkat Sala Kamreuk, Siem Reap, Cambodia',
    buyerPhone: '+855 88 112 233',
    quantityLabel: '100 bags',
    quantity: 100,
    productName: 'Cashew Nuts',
    unitPrice: 8.20,
    unitWeightKg: 0.25,
    total: 820.00,
    imageQuery: 'roasted,cashew,nuts',
    icon: Icons.eco_outlined,
    // Siem Reap is outside Grab Express's Phnom Penh-only coverage — J&T
    // Express runs nationwide.
    deliveryMethod: kJtExpressCarrier,
  ),
  SellerOrder(
    id: 'BD-98365',
    date: 'Oct 15, 2025',
    status: SellerOrderStatus.pending,
    buyerName: 'Ratana Pich',
    buyerAddress:
        'Preah Monivong Blvd, Sangkat Boeung Keng Kang 1, Khan '
        'Boeung Keng Kang, Phnom Penh, Cambodia',
    buyerPhone: '+855 70 998 112',
    quantityLabel: '1 unit',
    quantity: 1,
    productName: 'Cashew Nuts (Sample)',
    unitPrice: 12.50,
    unitWeightKg: 0.5,
    total: 12.50,
    imageQuery: 'roasted,cashew,nuts',
    icon: Icons.eco_outlined,
    // A single light sample within Phnom Penh — same-day Grab Express.
    deliveryMethod: kGrabExpressCarrier,
  ),
  SellerOrder(
    id: 'BD-98521',
    date: 'Nov 2, 2025',
    status: SellerOrderStatus.completed,
    buyerName: 'Chea Samnang',
    buyerAddress:
        'Angkor Wholesale Distribution, Russian Federation Blvd, Sangkat '
        'Toeuk Thla, Khan Sen Sok, Phnom Penh, Cambodia',
    buyerPhone: '+855 12 345 678',
    quantityLabel: '500 bags',
    quantity: 500,
    productName: 'Premium Jasmine Rice',
    unitPrice: 37.50,
    unitWeightKg: 5.0,
    total: 18750.00,
    imageQuery: 'jasmine,rice,bag',
    icon: Icons.rice_bowl_outlined,
    isCoBuy: true,
    // 2.5 tonnes — a full wholesale pallet. Vireak Buntham's bus-cargo
    // network handles this at its bulk freight rate; picked here to show
    // that route's pricing on a genuinely heavy Co-Buy order.
    deliveryMethod: kVireakBunthamCarrier,
  ),
  SellerOrder(
    id: 'BD-98498',
    date: 'Oct 30, 2025',
    status: SellerOrderStatus.completed,
    buyerName: 'Ly Sokha',
    buyerAddress: 'National Road 5, Sangkat Svay Por, Battambang, Cambodia',
    buyerPhone: '+855 77 654 321',
    quantityLabel: '300 bags',
    quantity: 300,
    productName: 'Organic Brown Rice',
    unitPrice: 28.00,
    unitWeightKg: 2.0,
    total: 8400.00,
    imageQuery: 'rice,sack',
    icon: Icons.rice_bowl_outlined,
    isCoBuy: true,
    // 600kg to another province — bus-freight rate via Vireak Buntham,
    // shown here alongside a J&T-carried heavy order for comparison.
    deliveryMethod: kVireakBunthamCarrier,
  ),
];
