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

/// Fade-through: the old page fades out and drifts up while the new one
/// fades in from below with a slight scale, so navigation feels continuous.
CustomTransitionPage<void> _fadeThroughPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final inCurve = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
      );
      final outCurve = CurvedAnimation(
        parent: secondaryAnimation,
        curve: const Interval(0, 0.5, curve: Curves.easeIn),
      );
      return FadeTransition(
        opacity: ReverseAnimation(outCurve),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(0, -0.015),
          ).animate(outCurve),
          child: FadeTransition(
            opacity: inCurve,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.035),
                end: Offset.zero,
              ).animate(inCurve),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.985, end: 1).animate(inCurve),
                child: child,
              ),
            ),
          ),
        ),
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
