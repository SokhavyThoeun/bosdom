import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Green seal with a white check, used next to verified seller names.
class VerifiedBadgeIcon extends StatelessWidget {
  const VerifiedBadgeIcon({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Fills the seal's check cutout so the check reads white on any
        // background.
        Container(
          width: size * 0.6,
          height: size * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        Icon(Icons.verified, size: size, color: AppColors.trustGreen),
      ],
    );
  }
}
