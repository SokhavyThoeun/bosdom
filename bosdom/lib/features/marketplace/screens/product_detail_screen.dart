import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/widgets.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return AppPlaceholderScreen(
      title: 'Product $productId',
      subtitle: 'Sample vs. bulk pricing — UI comes in phase 3',
      actions: [
        AppButton(
          label: 'Buy sample',
          onPressed: () => context.goNamed('sampleGate'),
        ),
        const SizedBox(height: 12),
        AppButton(
          label: 'Start a co-buy',
          variant: AppButtonVariant.outlined,
          onPressed: () => context.goNamed('coBuying'),
        ),
      ],
    );
  }
}
