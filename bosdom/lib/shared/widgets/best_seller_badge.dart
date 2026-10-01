import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Small flat burgundy icon badge for top-tier sellers, used next to seller
/// names. Fixed color so it reads clearly on both light and dark row
/// backgrounds without needing a `light` variant. No visible label — the
/// seller name row is already busy — but the icon carries a tooltip so the
/// badge's meaning is still one tap/hover away.
class BestSellerBadge extends StatelessWidget {
  const BestSellerBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color: AppColors.deepBurgundy,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.workspace_premium, size: 12, color: Colors.white),
      ),
    );
  }
}
