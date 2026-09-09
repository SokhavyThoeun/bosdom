import '../../../shared/utils/mock_images.dart';

class SellerListing {
  const SellerListing({
    required this.name,
    required this.price,
    required this.stockLabel,
    required this.imageQuery,
    this.active = true,
  });

  final String name;
  final double price;
  final String stockLabel;
  final String imageQuery;
  final bool active;

  String get imageUrl => mockPhotoUrl(imageQuery, name);

  SellerListing copyWith({bool? active}) => SellerListing(
    name: name,
    price: price,
    stockLabel: stockLabel,
    imageQuery: imageQuery,
    active: active ?? this.active,
  );
}

const kMockSellerListings = [
  SellerListing(
    name: 'Organic Kampot Black Pepper',
    price: 12.50,
    stockLabel: '500 bags',
    imageQuery: 'black,pepper',
  ),
  SellerListing(
    name: 'Premium Jasmine Rice AAA',
    price: 45.00,
    stockLabel: '1,200 bags',
    imageQuery: 'jasmine,rice,bag',
  ),
  SellerListing(
    name: 'Raw Cashew Nuts (Grade W240)',
    price: 8.20,
    stockLabel: '350 bags',
    imageQuery: 'roasted,cashew,nuts',
    active: false,
  ),
  SellerListing(
    name: 'Dehydrated Honey Mango Slices',
    price: 15.40,
    stockLabel: '280 boxes',
    imageQuery: 'dried,mango',
  ),
];
