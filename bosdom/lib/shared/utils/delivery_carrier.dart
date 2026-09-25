/// Maps a delivery method name to its carrier logo asset.
///
/// Matches the carrier logos offered on the checkout delivery-method step —
/// only these three couriers are ever assigned to an order. Shared by every
/// screen that shows a "Delivery Method" section (buyer order detail,
/// seller order detail) so the same method always renders the same logo.
String? deliveryLogoAsset(String deliveryMethod) => switch (deliveryMethod) {
  // 'Vireak Buntham Express' is the legacy name on orders placed earlier.
  'VET Logistic' ||
  'Vireak Buntham Express' => 'assets/images/shipping/vet-express.png',
  'J&T Express' => 'assets/images/shipping/jt-express.png',
  'Grab Express' => 'assets/images/shipping/grab-express.png',
  _ => null,
};
