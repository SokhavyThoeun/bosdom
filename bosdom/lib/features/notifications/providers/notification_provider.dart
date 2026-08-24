import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import '../services/notification_service.dart';

class NotificationState {
  const NotificationState({required this.items, required this.unreadCount});

  final List<AppNotification> items;
  final int unreadCount;
}

class NotificationNotifier extends AsyncNotifier<NotificationState> {
  @override
  Future<NotificationState> build() async {
    final page = await NotificationService.fetchAll();
    return NotificationState(items: page.items, unreadCount: page.unreadCount);
  }

  Future<void> refresh() async {
    final page = await NotificationService.fetchAll();
    state = AsyncData(
      NotificationState(items: page.items, unreadCount: page.unreadCount),
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
