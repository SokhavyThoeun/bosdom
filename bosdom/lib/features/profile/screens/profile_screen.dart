import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScreen(
      title: 'Profile',
      subtitle: 'Business info & verification badge — UI comes in phase 7',
      actions: [
        AppButton(
          label: 'View escrow order',
          variant: AppButtonVariant.outlined,
          onPressed: () => context.goNamed('escrow'),
        ),
      ],
    );
  }
}
