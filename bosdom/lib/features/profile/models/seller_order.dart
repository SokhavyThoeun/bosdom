import '../../orders/models/order.dart';

/// Seller-facing wording for the real escrow [OrderStatus] — a seller thinks
/// in terms of "do I need to ship this?" rather than the buyer-facing escrow
/// terminology, even though it's the same underlying status.
///
/// `held` is split into two seller-facing states even though the backend
/// only tracks one: until the seller taps Confirm Order, it still needs
/// their action, so it reads "Awaiting Confirmation" rather than the more
/// passive "Processing".
String sellerOrderStatusLabel(
  OrderStatus status, {
  bool isSellerConfirmed = true,
}) => switch (status) {
  OrderStatus.pendingPayment => 'Pending',
  OrderStatus.held =>
    isSellerConfirmed ? 'Processing' : 'Awaiting Confirmation',
  OrderStatus.released => 'Completed',
  OrderStatus.disputed => 'Disputed',
  OrderStatus.refunded => 'Refunded',
  OrderStatus.cancelled => 'Cancelled',
};

/// Standard platform commission (4%; 3% for sellers with more than 40
/// confirmed orders in a month — see `fee_rate_for` in the backend) taken out of every order's subtotal before it's paid
/// out to the seller — shown on the seller earnings screen.
const kSellerPlatformFeeRate = 0.04;
