import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScreen(
      title: 'Log in',
      subtitle: 'Login flow — UI comes in phase 2',
      actions: [
        AppButton(
          label: 'Continue to marketplace',
          onPressed: () => context.goNamed('marketplace'),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Sign up instead',
          variant: AppButtonVariant.text,
          onPressed: () => context.goNamed('signup'),
        ),
      ],
    );
  }
}
