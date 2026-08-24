import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';

class OrdersNotifier extends Notifier<List<Order>> {
  @override
  List<Order> build() => [...kMockOrders];

  void addOrder(Order order) {
    state = [order, ...state];
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, List<Order>>(
  OrdersNotifier.new,
);
