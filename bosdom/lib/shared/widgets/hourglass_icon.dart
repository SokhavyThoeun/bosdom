import 'dart:math' as math;

import 'package:flutter/material.dart';

/// An hourglass with sand that actually drains from the top chamber into
/// the bottom one through a falling stream, then flips over and repeats —
/// used anywhere the app shows a "waiting on review/confirmation" state.
///
/// The silhouette is chunky and rounded (wide trapezoid bulbs, short
/// rounded neck) to match the classic bold hourglass glyph rather than a
/// thin-lined shape.
class HourglassIcon extends StatefulWidget {
  const HourglassIcon({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<HourglassIcon> createState() => _HourglassIconState();
}

class _HourglassIconState extends State<HourglassIcon>
    with SingleTickerProviderStateMixin {
  // Weights mirror one physical cycle: sand drains while the glass sits
  // still, then it flips, then it drains again (now upside down), then
  // flips back — so the loop is seamless.
  static const _drainWeight = 42.0;
  static const _flipWeight = 16.0;
  static const _totalWeight = 2 * _drainWeight + 2 * _flipWeight;
  static const _seg1End = _drainWeight / _totalWeight;
  static const _seg2End = (_drainWeight + _flipWeight) / _totalWeight;
  static const _seg3End = (2 * _drainWeight + _flipWeight) / _totalWeight;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  late final Animation<double> _angle = TweenSequence<double>([
    TweenSequenceItem(tween: ConstantTween(0), weight: _drainWeight),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: math.pi,
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: _flipWeight,
    ),
    TweenSequenceItem(tween: ConstantTween(math.pi), weight: _drainWeight),
    TweenSequenceItem(
      tween: Tween(
        begin: math.pi,
        end: 2 * math.pi,
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
      weight: _flipWeight,
    ),
  ]).animate(_controller);

  // Fraction of sand that has moved into the (local) bottom chamber: 0 when
  // it's all still up top, 1 once it's all drained down.
  late final Animation<double> _sandDrained = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 0.0,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInSine)),
      weight: _drainWeight,
    ),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: _flipWeight),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeInSine)),
      weight: _drainWeight,
    ),
    TweenSequenceItem(tween: ConstantTween(0.0), weight: _flipWeight),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final v = _controller.value;
        final isDraining = v < _seg1End || (v >= _seg2End && v < _seg3End);
        // A couple of grains loop down through the neck several times per
        // drain phase, offset from each other for a continuous trickle.
        final grainT = (v * 6) % 1.0;
        return Transform.rotate(
          angle: _angle.value,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _HourglassPainter(
              color: widget.color,
              sandDrained: _sandDrained.value,
              isDraining: isDraining,
              grainT: grainT,
            ),
          ),
        );
      },
    );
  }
}

/// Builds a closed path through [points] with each corner rounded off by
/// [radius] (clamped to half of its shortest adjacent edge).
Path _roundedPolygonPath(List<Offset> points, double radius) {
  final path = Path();
  final n = points.length;
  for (var i = 0; i < n; i++) {
    final prev = points[(i - 1 + n) % n];
    final curr = points[i];
    final next = points[(i + 1) % n];
    final toPrev = prev - curr;
    final toNext = next - curr;
    final lenPrev = toPrev.distance;
    final lenNext = toNext.distance;
    final r = math.min(radius, math.min(lenPrev, lenNext) / 2);
    final p1 = curr + toPrev / lenPrev * r;
    final p2 = curr + toNext / lenNext * r;
    if (i == 0) {
      path.moveTo(p1.dx, p1.dy);
    } else {
      path.lineTo(p1.dx, p1.dy);
    }
    path.quadraticBezierTo(curr.dx, curr.dy, p2.dx, p2.dy);
  }
  path.close();
  return path;
}

class _HourglassPainter extends CustomPainter {
  _HourglassPainter({
    required this.color,
    required this.sandDrained,
    required this.isDraining,
    required this.grainT,
  });

  final Color color;
  final double sandDrained;
  final bool isDraining;
  final double grainT;

  // Geometry laid out in a 24x24 unit box, scaled to the requested size —
  // wide rounded trapezoid bulbs with a short neck, like the classic bold
  // hourglass glyph.
  static const _left = 6.5;
  static const _right = 17.5;
  static const _capTopOuter = 3.4;
  static const _capTopInner = 5.4;
  static const _capBottomInner = 18.6;
  static const _capBottomOuter = 20.6;
  static const _neckX = 12.0;
  static const _neckHalfWidth = 0.85;
  static const _neckTopY = 11.3;
  static const _neckBottomY = 12.7;
  static const _cornerRadius = 1.2;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale);

    final glassPaint = Paint()
      ..color = color.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final capPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final sandPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const topLeft = Offset(_left, _capTopInner);
    const topRight = Offset(_right, _capTopInner);
    const neckTopLeft = Offset(_neckX - _neckHalfWidth, _neckTopY);
    const neckTopRight = Offset(_neckX + _neckHalfWidth, _neckTopY);
    const neckTopMid = Offset(_neckX, _neckTopY);

    const bottomLeft = Offset(_left, _capBottomInner);
    const bottomRight = Offset(_right, _capBottomInner);
    const neckBottomLeft = Offset(_neckX - _neckHalfWidth, _neckBottomY);
    const neckBottomRight = Offset(_neckX + _neckHalfWidth, _neckBottomY);
    const neckBottomMid = Offset(_neckX, _neckBottomY);

    // Caps.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(
          _left - 0.4,
          _capTopOuter,
          _right + 0.4,
          _capTopInner,
        ),
        const Radius.circular(0.9),
      ),
      capPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTRB(
          _left - 0.4,
          _capBottomInner,
          _right + 0.4,
          _capBottomOuter,
        ),
        const Radius.circular(0.9),
      ),
      capPaint,
    );

    // Sand remaining up top: a triangle anchored at the neck, shrinking
    // toward it as it drains.
    final amtTop = 1.0 - sandDrained;
    if (amtTop > 0.01) {
      final path = Path()
        ..moveTo(neckTopMid.dx, neckTopMid.dy)
        ..lineTo(
          _lerpToward(neckTopMid, topLeft, amtTop).dx,
          _lerpToward(neckTopMid, topLeft, amtTop).dy,
        )
        ..lineTo(
          _lerpToward(neckTopMid, topRight, amtTop).dx,
          _lerpToward(neckTopMid, topRight, amtTop).dy,
        )
        ..close();
      canvas.drawPath(path, sandPaint);
    }

    // Sand piling up at the bottom: a triangle anchored at the base,
    // growing taller toward the neck as it fills.
    final amtBottom = sandDrained;
    if (amtBottom > 0.01) {
      const baseMid = Offset(_neckX, _capBottomInner);
      final apex = Offset.lerp(baseMid, neckBottomMid, amtBottom)!;
      final path = Path()
        ..moveTo(bottomLeft.dx, bottomLeft.dy)
        ..lineTo(bottomRight.dx, bottomRight.dy)
        ..lineTo(apex.dx, apex.dy)
        ..close();
      canvas.drawPath(path, sandPaint);
    }

    // Falling stream through the neck while actively draining.
    if (isDraining && sandDrained > 0.02 && sandDrained < 0.98) {
      final streamPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.4
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        const Offset(_neckX, _neckTopY - 0.1),
        const Offset(_neckX, _neckBottomY + 0.1),
        streamPaint,
      );

      final grainPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      for (final phase in [0.0, 0.5]) {
        final t = (grainT + phase) % 1.0;
        final y = _neckTopY - 0.2 + t * (_neckBottomY - _neckTopY + 0.4);
        canvas.drawCircle(Offset(_neckX, y), 0.42, grainPaint);
      }
    }

    // Glass outline drawn last, over the sand: two wide rounded trapezoid
    // bulbs pinched by a short neck — a bolder, chunkier silhouette than a
    // thin-lined triangle.
    final topBulb = _roundedPolygonPath([
      topLeft,
      topRight,
      neckTopRight,
      neckTopLeft,
    ], _cornerRadius);
    final bottomBulb = _roundedPolygonPath([
      neckBottomLeft,
      neckBottomRight,
      bottomRight,
      bottomLeft,
    ], _cornerRadius);
    canvas.drawPath(topBulb, glassPaint);
    canvas.drawPath(bottomBulb, glassPaint);

    canvas.restore();
  }

  Offset _lerpToward(Offset anchor, Offset target, double t) =>
      Offset.lerp(anchor, target, t)!;

  @override
  bool shouldRepaint(_HourglassPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.sandDrained != sandDrained ||
      oldDelegate.isDraining != isDraining ||
      oldDelegate.grainT != grainT;
}
