import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/listings/listings_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/sellers/sellers_screen.dart';
import '../../features/support/support_screen.dart';
import '../../features/users/users_screen.dart';
import '../../shared/widgets/admin_shell.dart';
import '../auth/admin_session.dart';

CustomTransitionPage<void> _fadeThroughPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.02),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  refreshListenable: adminSession,
  redirect: (context, state) {
    if (!adminSession.restored) return null;
    final loggingIn = state.matchedLocation == '/login';
    if (!adminSession.isLoggedIn && !loggingIn) return '/login';
    if (adminSession.isLoggedIn && loggingIn) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) =>
          _fadeThroughPage(state, const LoginScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          AdminShell(location: state.matchedLocation, child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) =>
              _fadeThroughPage(state, const DashboardScreen()),
        ),
        GoRoute(
          path: '/sellers',
          pageBuilder: (context, state) =>
              _fadeThroughPage(state, const SellersScreen()),
        ),
        GoRoute(
          path: '/listings',
          pageBuilder: (context, state) =>
              _fadeThroughPage(state, const ListingsScreen()),
        ),
        GoRoute(
          path: '/orders',
          pageBuilder: (context, state) =>
              _fadeThroughPage(state, const OrdersScreen()),
        ),
        GoRoute(
          path: '/support',
          pageBuilder: (context, state) => _fadeThroughPage(
            state,
            SupportScreen(
              key: ValueKey(state.uri.queryParameters['conversation']),
              initialConversationId: state.uri.queryParameters['conversation'],
            ),
          ),
        ),
        GoRoute(
          path: '/users',
          pageBuilder: (context, state) =>
              _fadeThroughPage(state, const UsersScreen()),
        ),
      ],
    ),
  ],
);
