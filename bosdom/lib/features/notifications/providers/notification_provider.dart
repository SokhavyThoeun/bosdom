import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/models/merchant_role.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationState {
  const NotificationState({required this.items, required this.unreadCount});

  final List<AppNotification> items;
  final int unreadCount;
}

// Fund-movement alerts (escrow releases, invoice payments) are seller
// bookkeeping noise for a buyer — buyers only care about their order status,
// store messages, and co-buy outcomes.
const _kSellerOnlyCategories = {
  NotificationCategory.escrow,
  NotificationCategory.payment,
};

class NotificationNotifier extends AsyncNotifier<NotificationState> {
  @override
  Future<NotificationState> build() async {
    final page = await NotificationService.fetchAll();
    return _stateForRole(page.items);
  }

  Future<void> refresh() async {
    final page = await NotificationService.fetchAll();
    state = AsyncData(await _stateForRole(page.items));
  }

  Future<NotificationState> _stateForRole(List<AppNotification> items) async {
    final profile = await ref.watch(profileProvider.future);
    final isSeller = profile.role == MerchantRole.supplier.name;
    final visible = isSeller
        ? items
        : items
              .where((n) => !_kSellerOnlyCategories.contains(n.category))
              .toList();
    return NotificationState(
      items: visible,
      unreadCount: visible.where((n) => !n.read).length,
    );
  }

  Future<void> markRead(String id) async {
    final current = state.value;
    if (current == null) return;
    final target = current.items.firstWhere((n) => n.id == id);
    if (target.read) return;

    final optimistic = [
      for (final n in current.items)
        if (n.id == id) n.copyWith(read: true) else n,
    ];
    state = AsyncData(
      NotificationState(
        items: optimistic,
        unreadCount: (current.unreadCount - 1).clamp(0, 1 << 30),
      ),
    );

    final unreadCount = await NotificationService.markRead(id);
    final latest = state.value;
    if (latest != null) {
      state = AsyncData(NotificationState(items: latest.items, unreadCount: unreadCount));
    }
  }

  Future<void> markAllRead() async {
    final current = state.value;
    if (current == null) return;

    final optimistic = [for (final n in current.items) n.copyWith(read: true)];
    state = AsyncData(NotificationState(items: optimistic, unreadCount: 0));

    await NotificationService.markAllRead();
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, NotificationState>(
      NotificationNotifier.new,
    );

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).value?.unreadCount ?? 0;
});
