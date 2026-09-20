import 'package:flutter/material.dart';

import 'core/auth/admin_session.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restored before the router evaluates its first redirect, so the app
  // never flashes an unauthenticated dashboard before landing on /login.
  await adminSession.restore();
  runApp(const BosdomAdminApp());
}

class BosdomAdminApp extends StatelessWidget {
  const BosdomAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BosDom Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
