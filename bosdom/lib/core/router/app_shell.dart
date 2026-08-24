import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/floating_nav_bar.dart';

/// Bottom-nav shell wrapping the persistent post-auth tabs. Preserves each
/// tab's navigation stack.
///
/// The floating pill is the only thing in the `bottomNavigationBar` slot — no
/// wrapping surface — and `extendBody` lets tab content scroll behind it, so
/// nothing paints a rectangle along the bottom edge.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      extendBody: true,
      // extendBody draws the body behind the pill and hands it a bottom padding
      // equal to the pill's height, so each tab's SafeArea rests its content
      // above the pill while still scrolling behind it.
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FloatingNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          items: [
            FloatingNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: l10n.navHome,
            ),
            FloatingNavItem(
              icon: Icons.search_outlined,
              activeIcon: Icons.search,
              label: l10n.navSearch,
            ),
            FloatingNavItem(
              icon: Icons.favorite_border,
              activeIcon: Icons.favorite,
              label: l10n.navWishlist,
            ),
            FloatingNavItem(
              icon: Icons.shopping_bag_outlined,
              activeIcon: Icons.shopping_bag,
              label: l10n.navCart,
            ),
            FloatingNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: l10n.navAccount,
            ),
          ],
        ),
      ),
    );
  }
}
