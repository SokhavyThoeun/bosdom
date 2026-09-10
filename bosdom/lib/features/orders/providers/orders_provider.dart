import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// detail/tracking screens — mirrors `listingByIdProvider`/`orderByIdProvider`
/// precedent from 16.2/16.4 so those screens don't depend on the list having
/// already loaded.
final orderByIdProvider = FutureProvider.family<Order, String>(
  (ref, orderId) => OrderService.fetchOrder(orderId),
);
