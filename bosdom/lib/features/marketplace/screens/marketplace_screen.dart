import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/widgets.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScreen(
      title: 'Marketplace',
      subtitle: 'Wholesale catalog browse — UI comes in phase 3',
      actions: [
        AppButton(
          label: 'View sample product',
          onPressed: () => context.goNamed(
            'productDetail',
            pathParameters: {'id': 'sample'},
          ),
        ),
      ],
    );
  }
}
