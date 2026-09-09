import 'package:flutter/material.dart';

import '../../../shared/models/variant_option.dart';
import '../../../shared/utils/mock_images.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.moq,
    required this.seller,
    required this.icon,
    required this.category,
    required this.imageQuery,
    this.moqValue = 10,
    this.samplePrice,
    this.rating = 4.5,
    this.location = 'Phnom Penh, Cambodia',
    this.verified = true,
    this.inStock = true,
    this.weight = '-',
    this.origin = 'Cambodia',
    this.grade = 'Standard',
    this.packaging = '-',
    this.deliveryFee = 0,
    this.sizes = const [],
    this.colorOptions = const [],
    this.photoUrl,
    this.sellerLogoOverride,
    this.sellerId,
  });

  /// Backend listing id for real products, or a stringified index into
  /// [kMockProducts] for mock ones (matches the existing index-based
  /// routing/lookup convention still used by cart/wishlist/orders).
  final String id;
  final String name;
  final String price;
  final String moq;
  final String seller;
  final IconData icon;
  final String category;

  /// Keyword(s) used to fetch a category/topic-matched mock photo.
  final String imageQuery;
  final int moqValue;
  final String? samplePrice;
  final double rating;
  final String location;
  final bool verified;
  final bool inStock;
  final String weight;
  final String origin;
  final String grade;
  final String packaging;

  /// Flat delivery fee set by the seller for this product. `0` means the
  /// seller offers free delivery.
  final double deliveryFee;

  /// Selectable sizes (e.g. clothing). Empty when the product has no size
  /// variants.
  final List<String> sizes;

  /// Selectable colors. Empty when the product has no color variants.
  final List<ProductColorOption> colorOptions;

  /// Real seller-uploaded photo URL for a backend-sourced listing. `null`
  /// for mock products, which fall back to [imageUrl]'s curated mock photo.
  final String? photoUrl;

  /// Real shop logo URL for a backend-sourced listing's seller. `null` for
  /// mock products, which fall back to [sellerLogoUrl]'s generated mock logo.
  final String? sellerLogoOverride;

  /// Real backend user id of the seller, for starting a chat conversation.
  /// `null` for mock products, which have no real counterpart to message.
  final String? sellerId;

  bool get hasVariants => sizes.isNotEmpty || colorOptions.isNotEmpty;

  bool get hasFreeDelivery => deliveryFee == 0;

  String get deliveryFeeLabel =>
      hasFreeDelivery ? 'Free Delivery' : '\$${deliveryFee.toStringAsFixed(2)} delivery fee';

  /// The listing's real photo when available, else a category/topic-matched
  /// mock photo.
  String get imageUrl => photoUrl ?? mockPhotoUrl(imageQuery, name);

  /// The seller's real shop logo when available, else a generated mock logo.
  String get sellerLogoUrl => sellerLogoOverride ?? mockStoreLogoUrl(seller);

  double get priceValue => double.parse(price.replaceFirst('\$', ''));

  double get samplePriceValue => samplePrice != null
      ? double.parse(samplePrice!.replaceFirst('\$', ''))
      : priceValue;
}

const kMockProducts = [
  Product(
    id: '0',
    name: 'Premium Jasmine Rice Bulk Bag (25kg)',
    price: '\$18.50',
    samplePrice: '\$22.50',
    moq: 'MOQ: 20 Bags',
    moqValue: 20,
    seller: 'Mekong Agri-Food Co.',
    icon: Icons.rice_bowl_outlined,
    category: 'Food & Bev',
    imageQuery: 'rice,sack',
    rating: 4.5,
    weight: '25kg per bag',
    origin: 'Cambodia',
    grade: 'Premium AA',
    packaging: 'Woven PP bag',
    deliveryFee: 5,
  ),
  Product(
    id: '1',
    name: 'Biodegradable Paper Hot Cups (1000 Pcs)',
    price: '\$24.00',
    moq: 'MOQ: 5 Boxes',
    seller: 'EcoPack Cambodia',
    icon: Icons.local_cafe_outlined,
    category: 'Home',
    imageQuery: 'paper,cup',
    deliveryFee: 3.5,
  ),
  Product(
    id: '2',
    name: 'Universal USB-C Fast Charger Bulk Pack',
    price: '\$2.80',
    moq: 'MOQ: 100 Units',
    seller: 'PP Tech Import',
    icon: Icons.bolt_outlined,
    category: 'Electronics',
    imageQuery: 'usb,charger',
    deliveryFee: 8,
  ),
  Product(
    id: '3',
    name: 'Organic Cold Pressed Coconut Oil (1L)',
    price: '\$6.50',
    moq: 'MOQ: 12 Bottles',
    seller: 'Angkor BioSource',
    icon: Icons.spa_outlined,
    category: 'Food & Bev',
    imageQuery: 'coconut,oil',
  ),
  Product(
    id: '4',
    name: 'Heavy Duty Cotton Canvas Tote Bags',
    price: '\$1.10',
    moq: 'MOQ: 500 Units',
    seller: 'Angkor Garment Factory',
    icon: Icons.shopping_bag_outlined,
    category: 'Clothing',
    imageQuery: 'tote,bag',
    deliveryFee: 6,
    colorOptions: [
      ProductColorOption('Natural', Color(0xFFE8DCC8)),
      ProductColorOption('Black', Color(0xFF1A1A1A)),
      ProductColorOption('Navy', Color(0xFF243B55)),
      ProductColorOption('Forest Green', Color(0xFF2F5233)),
    ],
  ),
  Product(
    id: '5',
    name: 'Industrial Microfiber Cleaning Cloths',
    price: '\$0.45',
    moq: 'MOQ: 1000 Pcs',
    seller: 'Phnom Penh Cleaners',
    icon: Icons.cleaning_services_outlined,
    category: 'Home',
    imageQuery: 'cleaning,cloth',
    deliveryFee: 4,
  ),
  Product(
    id: '6',
    name: 'Wholesale Assorted Snack Mix (5kg)',
    price: '\$12.90',
    moq: 'MOQ: 10 Bags',
    seller: 'SnackHub Wholesale',
    icon: Icons.fastfood_outlined,
    category: 'Food & Bev',
    imageQuery: 'snack,mix',
    deliveryFee: 2.5,
  ),
  Product(
    id: '7',
    name: 'Bulk Cotton Face Masks (500 Pcs)',
    price: '\$45.00',
    moq: 'MOQ: 500 Units',
    seller: 'Angkor Garment Factory',
    icon: Icons.masks_outlined,
    category: 'Beauty',
    imageQuery: 'face,mask',
    deliveryFee: 6,
    sizes: ['Kids', 'Adult'],
    colorOptions: [
      ProductColorOption('White', Color(0xFFFFFFFF)),
      ProductColorOption('Black', Color(0xFF1A1A1A)),
      ProductColorOption('Sky Blue', Color(0xFF7EC8E3)),
    ],
  ),
  Product(
    id: '8',
    name: 'Stainless Steel Water Bottles (500ml)',
    price: '\$3.20',
    moq: 'MOQ: 200 Units',
    seller: 'Mekong Agri-Food Co.',
    icon: Icons.water_drop_outlined,
    category: 'Home',
    imageQuery: 'water,bottle',
    deliveryFee: 5,
  ),
  Product(
    id: '9',
    name: 'Wireless Earbuds Bulk Pack (10 Units)',
    price: '\$19.00',
    moq: 'MOQ: 10 Packs',
    seller: 'PP Tech Import',
    icon: Icons.headset_outlined,
    category: 'Electronics',
    imageQuery: 'wireless,earbuds',
    deliveryFee: 8,
  ),
  Product(
    id: '10',
    name: 'Wholesale T-Shirts (Pack of 12)',
    price: '\$36.00',
    moq: 'MOQ: 12 Packs',
    seller: 'Apparel Hub',
    icon: Icons.checkroom_outlined,
    category: 'Clothing',
    imageQuery: 'tshirt,stack',
    deliveryFee: 7,
    sizes: ['S', 'M', 'L', 'XL', 'XXL'],
    colorOptions: [
      ProductColorOption('White', Color(0xFFFFFFFF)),
      ProductColorOption('Black', Color(0xFF1A1A1A)),
      ProductColorOption('Navy', Color(0xFF243B55)),
      ProductColorOption('Red', Color(0xFFB3261E)),
      ProductColorOption('Heather Gray', Color(0xFF9E9E9E)),
    ],
  ),
  Product(
    id: '11',
    name: 'Kitchen Towel Rolls (48 Rolls)',
    price: '\$28.00',
    moq: 'MOQ: 48 Rolls',
    seller: 'Home Essentials',
    icon: Icons.countertops_outlined,
    category: 'Home',
    imageQuery: 'paper,towel',
    deliveryFee: 4.5,
  ),
  Product(
    id: '12',
    name: 'Natural Raw Brown Sugar (50kg)',
    price: '\$22.00',
    moq: 'MOQ: 15 Bags',
    seller: 'Mekong Agri-Food Co.',
    icon: Icons.grain_outlined,
    category: 'Food & Bev',
    imageQuery: 'brown,sugar',
    deliveryFee: 5,
  ),
  Product(
    id: '13',
    name: 'Premium Traditional Fish Sauce (750ml)',
    price: '\$3.80',
    moq: 'MOQ: 50 Bottles',
    seller: 'Phnom Penh Foods',
    icon: Icons.liquor_outlined,
    category: 'Food & Bev',
    imageQuery: 'fish,sauce',
    deliveryFee: 3,
  ),
  Product(
    id: '14',
    name: 'Organic Green Tea Bulk Pack (500g)',
    price: '\$8.90',
    moq: 'MOQ: 30 Packs',
    seller: 'Angkor BioSource',
    icon: Icons.emoji_food_beverage_outlined,
    category: 'Food & Bev',
    imageQuery: 'green,tea',
  ),
  Product(
    id: '15',
    name: 'Dried Organic Mango Slices (1kg)',
    price: '\$12.50',
    moq: 'MOQ: 25 Bags',
    seller: 'Mekong Agri-Food Co.',
    icon: Icons.eco_outlined,
    category: 'Food & Bev',
    imageQuery: 'dried,mango',
    deliveryFee: 5,
  ),
  Product(
    id: '16',
    name: 'Thai Premium Fish Sauce (Case of 12)',
    price: '\$38.50',
    moq: 'MOQ: 10 Cases',
    moqValue: 10,
    seller: 'Mekong Agri-Food Co.',
    icon: Icons.liquor_outlined,
    category: 'Food & Bev',
    imageQuery: 'fish,sauce',
    deliveryFee: 5,
  ),
  Product(
    id: '17',
    name: 'Organic Coconut Milk (Case of 24)',
    price: '\$41.35',
    moq: 'MOQ: 4 Cases',
    moqValue: 4,
    seller: 'Mekong Agri-Food Co.',
    icon: Icons.local_drink_outlined,
    category: 'Food & Bev',
    imageQuery: 'coconut,milk',
    deliveryFee: 5,
  ),
];
