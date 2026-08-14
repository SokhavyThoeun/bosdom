import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScreen(
      title: 'Bosdom',
      subtitle: 'Onboarding & splash flow',
      actions: [
        AppButton(label: 'Log in', onPressed: () => context.goNamed('login')),
        const SizedBox(height: 12),
        AppButton(
          label: 'Sign up',
          variant: AppButtonVariant.outlined,
          onPressed: () => context.goNamed('signup'),
        ),
      ],
    );
  }
}
