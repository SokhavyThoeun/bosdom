import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: BosdomApp()));
}

class BosdomApp extends StatelessWidget {
  const BosdomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bosdom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const RootScreen(),
    );
  }
}

/// Temporary root screen — replaced by go_router navigation in 1.5.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bosdom')),
      body: const Center(child: Text('Bosdom')),
    );
  }
}
