import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/widgets.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScreen(
      title: 'Sign up',
      subtitle: 'Retailer vs. supplier role selection — UI comes in phase 2',
      actions: [
        AppButton(
          label: 'Log in instead',
          variant: AppButtonVariant.text,
          onPressed: () => context.goNamed('login'),
        ),
      ],
    );
  }
}
