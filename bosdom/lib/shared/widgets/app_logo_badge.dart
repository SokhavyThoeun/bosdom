import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Circular BosDom brand mark used wherever a screen needs to show the
/// logo as an avatar (chat headers, support badges, etc). Mirrors the
/// splash screen's mark exactly — a soft radial glow behind the white
/// logo — so the brand reads identically everywhere. Meant to sit on a
/// colored (primary) background, same as the splash screen.
class AppLogoBadge extends StatelessWidget {
  const AppLogoBadge({
    super.key,
    this.size = 48,
    this.online = false,
    this.haloColor,
  });

  final double size;
  final bool online;

  /// Border color drawn around the online dot — should match whatever
  /// background this badge sits on (e.g. a colored header).
  final Color? haloColor;

  @override
  Widget build(BuildContext context) {
    final glowSize = size * 1.7;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: glowSize,
            height: glowSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.02),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0, 0.3, 0.6, 1],
              ),
            ),
          ),
          SizedBox(
            width: size * 0.85,
            height: size * 0.85,
            child: Image.asset(
              'assets/images/bosdom-logo-white.png',
              fit: BoxFit.contain,
            ),
          ),
          if (online)
            Positioned(
              right: size * 0.02,
              bottom: size * 0.02,
              child: Container(
                width: size * 0.26,
                height: size * 0.26,
                decoration: BoxDecoration(
                  color: AppColors.trustGreen,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: haloColor ?? Colors.white,
                    width: size * 0.045,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
