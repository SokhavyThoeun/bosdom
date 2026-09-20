import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';
import '../services/order_service.dart';

class OrdersNotifier extends AsyncNotifier<List<Order>> {
  @override
  Future<List<Order>> build() => OrderService.fetchMyOrders();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(OrderService.fetchMyOrders);
  }
}

final ordersProvider = AsyncNotifierProvider<OrdersNotifier, List<Order>>(
  OrdersNotifier.new,
);

/// A single order fetched independently of [ordersProvider]'s list, for the
/// detail/tracking screens — mirrors `listingByIdProvider` precedent from
/// 16.2/16.4 so those screens don't depend on the list having already
/// loaded. Also subscribes to Realtime updates on that one row, same pattern
/// as [SellerOrdersNotifier], so the buyer's delivery tracking screen
/// refreshes itself the moment the seller confirms the order instead of
/// requiring a pull-to-refresh.
class OrderByIdNotifier extends AsyncNotifier<Order> {
  OrderByIdNotifier(this.orderId);

  final String orderId;
  RealtimeChannel? _channel;

  @override
  Future<Order> build() async {
    final existingChannel = _channel;
    if (existingChannel != null) {
      Supabase.instance.client.removeChannel(existingChannel);
      _channel = null;
    }
    ref.onDispose(() {
      final channel = _channel;
      if (channel != null) Supabase.instance.client.removeChannel(channel);
    });

    final order = await OrderService.fetchOrder(orderId);
    _subscribeToChanges();
    return order;
  }

  /// Also listens for the buyer's review landing in the separate
  /// `order_reviews` table (insert on first submit, update on resubmit) —
  /// it doesn't touch `escrow_orders` itself, so without this the seller's
  /// (and the buyer's own, cross-session) order detail screen would never
  /// learn a review was left short of a manual refetch.
  void _subscribeToChanges() {
    void refetch(PostgresChangePayload payload) async {
      state = await AsyncValue.guard(() => OrderService.fetchOrder(orderId));
    }

    _channel = Supabase.instance.client
        .channel('escrow-order-$orderId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'escrow_orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: orderId,
          ),
          callback: refetch,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'order_reviews',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'order_id',
            value: orderId,
          ),
          callback: refetch,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'order_reviews',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'order_id',
            value: orderId,
          ),
          callback: refetch,
        )
        .subscribe();
  }
}

final orderByIdProvider =
    AsyncNotifierProvider.family<OrderByIdNotifier, Order, String>(
      OrderByIdNotifier.new,
    );

/// A seller's own sales — same [Order] shape as [ordersProvider], just
/// filtered server-side by `seller_id` instead of `buyer_id`
/// (`GET /orders/me/selling`).
class SellerOrdersNotifier extends AsyncNotifier<List<Order>> {
  RealtimeChannel? _channel;

  @override
  Future<List<Order>> build() async {
    final existingChannel = _channel;
    if (existingChannel != null) {
      Supabase.instance.client.removeChannel(existingChannel);
      _channel = null;
    }
    ref.onDispose(() {
      final channel = _channel;
      if (channel != null) Supabase.instance.client.removeChannel(channel);
    });

    final orders = await OrderService.fetchMySales();
    _subscribeToNewOrders();
    return orders;
  }

  /// Live order delivery: subscribes to inserts and updates on
  /// `escrow_orders` — RLS already scopes visible rows to the buyer/seller
  /// of each order (see the 16.7 migration), same pattern as
  /// [ChatNotifier]'s message subscription — so a new order a buyer places,
  /// or the admin releasing a payout, shows up here without the seller
  /// having to pull-to-refresh and potentially miss it.
  void _subscribeToNewOrders() {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId == null) return;

    Future<void> refetchIfMine(PostgresChangePayload payload) async {
      if (payload.newRecord['seller_id'] != currentUserId) return;
      state = await AsyncValue.guard(OrderService.fetchMySales);
    }

    _channel = Supabase.instance.client
        .channel('seller-orders-$currentUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'escrow_orders',
          callback: refetchIfMine,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'escrow_orders',
          callback: refetchIfMine,
        )
        .subscribe();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(OrderService.fetchMySales);
  }
}

final sellerOrdersProvider =
    AsyncNotifierProvider<SellerOrdersNotifier, List<Order>>(
      SellerOrdersNotifier.new,
    );

/// Real buyer reviews left on a seller's orders, keyed by seller id — shown
/// on the storefront's Reviews tab.
final sellerReviewsProvider = FutureProvider.autoDispose
    .family<List<OrderReview>, String>(
      (ref, sellerId) => OrderService.fetchSellerReviews(sellerId),
    );
