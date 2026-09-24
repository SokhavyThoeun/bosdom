import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api/admin_api_client.dart';
import '../../core/auth/admin_session.dart';
import '../../core/models/admin_models.dart';
import '../../core/theme/app_colors.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({required this.child, required this.location, super.key});

  final Widget child;
  final String location;

  static const _navItems = [
    _NavItem(
      '/dashboard',
      Icons.dashboard_outlined,
      Icons.dashboard,
      'Dashboard',
    ),
    _NavItem(
      '/sellers',
      Icons.storefront_outlined,
      Icons.storefront,
      'Sellers & Shops',
    ),
    _NavItem(
      '/listings',
      Icons.inventory_2_outlined,
      Icons.inventory_2,
      'Listings',
    ),
    _NavItem(
      '/orders',
      Icons.receipt_long_outlined,
      Icons.receipt_long,
      'Orders & Disputes',
    ),
    _NavItem('/users', Icons.people_outline, Icons.people, 'Buyers'),
    _NavItem(
      '/support',
      Icons.support_agent_outlined,
      Icons.support_agent,
      'Support Inbox',
    ),
  ];

  /// Below this window width the sidebar collapses to an icon-only rail so
  /// the page content keeps enough room.
  static const _compactBreakpoint = 960.0;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < _compactBreakpoint;
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: compact ? 76 : 256,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF6A1C1C), AppColors.deepBurgundy],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: compact
                        ? const EdgeInsets.symmetric(vertical: 24)
                        : const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Row(
                      mainAxisAlignment: compact
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/bosdom-logo-white.png',
                          height: 26,
                        ),
                        if (!compact) ...[
                          const SizedBox(width: 10),
                          const Flexible(
                            child: Text(
                              'BosDom Admin',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!compact)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          _AdminAvatar(size: 38),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BosDom Admin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                                Text(
                                  'Administrator',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Scrolls instead of overflowing on short windows.
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 4),
                      children: [
                        if (!compact)
                          const Padding(
                            padding: EdgeInsets.fromLTRB(28, 8, 20, 8),
                            child: Text(
                              'MENU',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        for (final item in _navItems)
                          _SidebarTile(
                            item: item,
                            compact: compact,
                            selected: location.startsWith(item.path),
                            onTap: () => context.go(item.path),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Divider(color: Colors.white12, height: 1),
                  ),
                  const SizedBox(height: 4),
                  Material(
                    type: MaterialType.transparency,
                    child: ListTile(
                      contentPadding: compact ? EdgeInsets.zero : null,
                      leading: Icon(
                        Icons.logout,
                        color: Colors.white70,
                        size: compact ? 20 : null,
                      ),
                      title: compact
                          ? null
                          : const Text(
                              'Log out',
                              style: TextStyle(color: Colors.white70),
                            ),
                      minLeadingWidth: compact ? 72 : null,
                      onTap: () async {
                        await adminSession.logout();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: const Color(0xFFF8F5F5),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopBar(location: location),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.path, this.icon, this.selectedIcon, this.label);
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.selected,
    required this.compact,
    required this.onTap,
  });

  final _NavItem item;
  final bool compact;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 14, vertical: 2),
      child: Tooltip(
        message: compact ? item.label : '',
        child: Material(
          color: selected
              ? Colors.white.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            hoverColor: Colors.white.withValues(alpha: 0.07),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 0 : 14,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: compact
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Icon(
                    selected ? item.selectedIcon : item.icon,
                    color: selected ? Colors.white : Colors.white70,
                    size: 20,
                  ),
                  if (!compact) ...[
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    required this.title,
    this.subtitle,
    this.actions,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(color: AppColors.warmTaupe, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          ...?actions,
        ],
      ),
    );
  }
}

class _AdminAvatar extends StatelessWidget {
  const _AdminAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.roseMist, AppColors.brandCrimson],
      ),
    ),
    child: Text(
      'B',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: size * 0.4,
      ),
    ),
  );
}

/// Breadcrumb bar shown above every page.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final current = AdminShell._navItems
        .where((i) => location.startsWith(i.path))
        .map((i) => i.label)
        .firstOrNull;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0x33DEC8C8))),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_outlined, size: 18, color: AppColors.warmTaupe),
          const SizedBox(width: 8),
          const Text(
            'Home',
            style: TextStyle(color: AppColors.warmTaupe, fontSize: 13.5),
          ),
          if (current != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.warmTaupe,
              ),
            ),
            Text(
              current,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const Spacer(),
          const _NotificationBell(),
          const SizedBox(width: 8),
          const _AdminAvatar(size: 34),
        ],
      ),
    );
  }
}

/// Bell in the top bar: a red count of everything still unread that is waiting
/// on an admin (support chats, reports, disputes, KYC, payouts, co-buy leaves)
/// with a panel that lists them by day. Polls so new items show up live.
class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

String _notificationId(AdminNotification n) =>
    '${n.kind}|${n.title}|${n.body}|${n.createdAt?.millisecondsSinceEpoch}';

class _NotificationBellState extends State<_NotificationBell> {
  static const _pollInterval = Duration(seconds: 15);
  static const _readKey = 'bosdom_admin_read_notifications';

  List<AdminNotification> _items = const [];
  final Set<String> _read = {};
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restoreRead().then((_) => _load());
    _timer = Timer.periodic(_pollInterval, (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _restoreRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _read.addAll(prefs.getStringList(_readKey) ?? const []);
    } catch (_) {}
  }

  Future<void> _persistRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Only remember ids that still exist, so the list can't grow forever.
      final live = {for (final n in _items) _notificationId(n)};
      _read.retainAll(live);
      await prefs.setStringList(_readKey, _read.toList());
    } catch (_) {}
  }

  Future<void> _load() async {
    try {
      final items = await AdminApiClient.fetchNotifications();
      if (mounted) setState(() => _items = items);
    } catch (_) {
      // Keep the last list; the next tick retries.
    }
  }

  int get _unread =>
      _items.where((n) => !_read.contains(_notificationId(n))).length;

  void _markRead(Iterable<AdminNotification> items) {
    setState(() => _read.addAll(items.map(_notificationId)));
    _persistRead();
  }

  Future<void> _open() async {
    await _load();
    if (!mounted) return;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close notifications',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 120),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
      pageBuilder: (dialogContext, _, _) => SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 64, right: 16, left: 16),
            child: _NotificationPanel(
              items: _items,
              read: _read,
              onChanged: (changed) => _markRead(changed),
              onOpen: (n) {
                _markRead([n]);
                Navigator.of(dialogContext).pop();
                context.go(n.route);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = _unread;
    return IconButton(
      tooltip: 'Notifications',
      onPressed: _open,
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        backgroundColor: AppColors.brandCrimson,
        child: const Icon(Icons.notifications_none_rounded),
      ),
    );
  }
}

class _NotificationPanel extends StatefulWidget {
  const _NotificationPanel({
    required this.items,
    required this.read,
    required this.onChanged,
    required this.onOpen,
  });

  final List<AdminNotification> items;
  final Set<String> read;
  final ValueChanged<List<AdminNotification>> onChanged;
  final ValueChanged<AdminNotification> onOpen;

  @override
  State<_NotificationPanel> createState() => _NotificationPanelState();
}

class _NotificationPanelState extends State<_NotificationPanel> {
  bool _isRead(AdminNotification n) => widget.read.contains(_notificationId(n));

  void _mark(List<AdminNotification> changed) {
    widget.onChanged(changed);
    setState(() {});
  }

  static String _dayLabel(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(DateTime(day.year, day.month, day.day));
    if (diff.inDays == 0) return 'TODAY';
    if (diff.inDays == 1) return 'YESTERDAY';
    return DateFormat('EEE, d MMM yyyy').format(day).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final unread = widget.items.where((n) => !_isRead(n)).length;

    // Newest first, grouped by calendar day (items without a time count as now).
    final rows = <Object>[];
    String? lastLabel;
    for (final n in widget.items) {
      final label = _dayLabel(n.createdAt ?? DateTime.now());
      if (label != lastLabel) {
        rows.add(label);
        lastLabel = label;
      }
      rows.add(n);
    }

    return Material(
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 440,
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 12),
                child: Row(
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (unread > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandCrimson,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: unread == 0 ? null : () => _mark(widget.items),
                      child: const Text(
                        'Mark all as read',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.roseDivider),
              if (widget.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Text(
                    'You\'re all caught up',
                    style: TextStyle(color: AppColors.warmTaupe),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      if (row is String) return _DayHeader(label: row);
                      final n = row as AdminNotification;
                      return _NotificationCard(
                        notification: n,
                        unread: !_isRead(n),
                        onToggleRead: () => _mark([n]),
                        onOpen: () => widget.onOpen(n),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F3F1),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.warmTaupe,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.unread,
    required this.onToggleRead,
    required this.onOpen,
  });

  final AdminNotification notification;
  final bool unread;
  final VoidCallback onToggleRead;
  final VoidCallback onOpen;

  static IconData _iconFor(String kind) => switch (kind) {
    'support' => Icons.support_agent,
    'report' => Icons.flag_outlined,
    'dispute' => Icons.report_problem_outlined,
    'kyc' => Icons.badge_outlined,
    'payout' => Icons.payments_outlined,
    'co_buy_leave' => Icons.group_remove_outlined,
    _ => Icons.info_outline,
  };

  static String _kindLabel(String kind) => switch (kind) {
    'support' => 'Support chat',
    'report' => 'Seller report',
    'dispute' => 'Dispute',
    'kyc' => 'Registration',
    'payout' => 'Payout',
    'co_buy_leave' => 'Co-buy',
    _ => 'Update',
  };

  static const _urgent = {'report', 'dispute'};

  @override
  Widget build(BuildContext context) {
    final n = notification;
    final at = n.createdAt;
    return InkWell(
      onTap: onOpen,
      child: Container(
        decoration: BoxDecoration(
          color: unread ? AppColors.petalWhite : Colors.white,
          border: const Border(bottom: BorderSide(color: Color(0x33DEC8C8))),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: unread ? AppColors.brandCrimson : Colors.transparent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: AppColors.blushSurface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _iconFor(n.kind),
                                size: 20,
                                color: AppColors.brandCrimson,
                              ),
                            ),
                            if (_urgent.contains(n.kind))
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: AppColors.ratingGold,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.priority_high,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: unread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              n.body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.warmTaupe,
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'VIEW',
                                  style: TextStyle(
                                    color: AppColors.brandCrimson,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                const Spacer(),
                                Flexible(
                                  child: Text(
                                    at == null
                                        ? _kindLabel(n.kind)
                                        : '${_kindLabel(n.kind)}   '
                                              '${DateFormat('d MMM yyyy HH:mm').format(at)}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.warmTaupe,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: unread ? 'Mark as read' : 'Read',
                        child: InkResponse(
                          onTap: unread ? onToggleRead : null,
                          radius: 16,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: unread
                                      ? AppColors.warmTaupe
                                      : AppColors.roseDivider,
                                  width: 1.5,
                                ),
                              ),
                              child: unread
                                  ? Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.warmTaupe,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
