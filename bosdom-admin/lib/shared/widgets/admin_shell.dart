import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/admin_session.dart';
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
          IconButton(
            tooltip: 'Support inbox',
            onPressed: () => context.go('/support'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
          const _AdminAvatar(size: 34),
        ],
      ),
    );
  }
}
