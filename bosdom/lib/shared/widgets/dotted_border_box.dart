import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// A dashed-border container, since [BoxBorder] has no built-in dashed style.
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({
    super.key,
    required this.color,
    required this.child,
    this.borderRadius = 16,
    this.showBorder = true,
  });

  final Color color;
  final Widget child;
  final double borderRadius;

  /// Whether to paint the dashed border. Pass `false` once a photo fills
  /// the tile — the dashes read as clutter on top of an actual image.
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: showBorder
          ? _DashedBorderPainter(color: color, radius: borderRadius)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blushSurface,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// A small circular "×" button overlaid on a photo tile to remove it.
class RemovePhotoButton extends StatelessWidget {
  const RemovePhotoButton({
    super.key,
    required this.onTap,
    this.size = 22,
    this.iconSize = 14,
  });

  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, size: iconSize, color: Colors.white),
      ),
    );
  }
}
