import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'motion.dart';

/// Tiny trend line for KPI cards.
class Sparkline extends StatelessWidget {
  const Sparkline({required this.values, required this.color, super.key});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) => DrawIn(
    child: CustomPaint(
      painter: _SparkPainter(values, color),
      size: Size.infinite,
    ),
  );
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.color);
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce(math.max);
    final range = maxV <= 0 ? 1.0 : maxV;
    final pts = [
      for (var i = 0; i < values.length; i++)
        Offset(
          i / (values.length - 1) * size.width,
          size.height - 3 - (values[i] / range) * (size.height - 6),
        ),
    ];
    final line = _smooth(pts);
    final fill = Path.from(line)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SparkPainter old) =>
      old.values != values || old.color != color;
}

Path _smooth(List<Offset> pts) {
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (var i = 0; i < pts.length - 1; i++) {
    final a = pts[i];
    final b = pts[i + 1];
    final midX = (a.dx + b.dx) / 2;
    path.cubicTo(midX, a.dy, midX, b.dy, b.dx, b.dy);
  }
  return path;
}

class ChartSeries {
  const ChartSeries(this.label, this.color, this.values);
  final String label;
  final Color color;
  final List<double> values;
}

/// Smooth overlapping area chart with a light grid and x labels.
class AreaChart extends StatelessWidget {
  const AreaChart({required this.series, required this.xLabels, super.key});

  final List<ChartSeries> series;
  final List<String> xLabels;

  @override
  Widget build(BuildContext context) => DrawIn(
    duration: const Duration(milliseconds: 1400),
    child: CustomPaint(
      painter: _AreaPainter(series, xLabels),
      size: Size.infinite,
    ),
  );
}

class _AreaPainter extends CustomPainter {
  _AreaPainter(this.series, this.xLabels);
  final List<ChartSeries> series;
  final List<String> xLabels;

  static const _left = 28.0;
  static const _bottom = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    final n = xLabels.length;
    if (n < 2) return;
    final plot = Rect.fromLTWH(
      _left,
      6,
      size.width - _left,
      size.height - _bottom - 6,
    );
    var maxV = 0.0;
    for (final s in series) {
      for (final v in s.values) {
        maxV = math.max(maxV, v);
      }
    }
    // Round the axis up to a clean number of gridlines.
    final top = math.max(4, maxV.ceil()).toDouble();
    final step = (top / 4).ceilToDouble();
    final axisMax = step * 4;

    final gridPaint = Paint()
      ..color = AppColors.roseDivider.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = plot.bottom - plot.height * i / 4;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _text(
        canvas,
        '${(step * i).toInt()}',
        Offset(0, y - 6),
        maxWidth: _left - 6,
        align: TextAlign.right,
      );
    }
    final labelEvery = (n / 7).ceil();
    for (var i = 0; i < n; i += labelEvery) {
      final x = plot.left + plot.width * i / (n - 1);
      _text(
        canvas,
        xLabels[i],
        Offset(x - 20, plot.bottom + 6),
        maxWidth: 40,
        align: TextAlign.center,
      );
    }

    for (final s in series) {
      final pts = [
        for (var i = 0; i < s.values.length; i++)
          Offset(
            plot.left + plot.width * i / (n - 1),
            plot.bottom - plot.height * (s.values[i] / axisMax),
          ),
      ];
      final line = _smooth(pts);
      final fill = Path.from(line)
        ..lineTo(plot.right, plot.bottom)
        ..lineTo(plot.left, plot.bottom)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              s.color.withValues(alpha: 0.32),
              s.color.withValues(alpha: 0.02),
            ],
          ).createShader(plot),
      );
      canvas.drawPath(
        line,
        Paint()
          ..color = s.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  void _text(
    Canvas canvas,
    String t,
    Offset at, {
    required double maxWidth,
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: t,
        style: const TextStyle(color: AppColors.warmTaupe, fontSize: 10.5),
      ),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: maxWidth, maxWidth: maxWidth);
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(_AreaPainter old) => true;
}

class DonutSlice {
  const DonutSlice(this.label, this.color, this.value);
  final String label;
  final Color color;
  final double value;
}

/// Ring chart with [center] widget inside.
class DonutChart extends StatelessWidget {
  const DonutChart({required this.slices, this.center, super.key});

  final List<DonutSlice> slices;
  final Widget? center;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 1000),
    curve: Curves.easeOutCubic,
    builder: (context, t, _) => CustomPaint(
      painter: _DonutPainter(slices, t),
      child: Center(child: center),
    ),
  );
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.slices, this.progress);
  final List<DonutSlice> slices;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 22.0;
    final d = math.min(size.width, size.height);
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: d - stroke,
      height: d - stroke,
    );
    final total = slices.fold<double>(0, (s, e) => s + e.value);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = AppColors.blushSurface;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    if (total <= 0) return;
    var start = -math.pi / 2;
    const gap = 0.04;
    for (final s in slices) {
      if (s.value <= 0) continue;
      final sweep = s.value / total * math.pi * 2 * progress;
      canvas.drawArc(
        rect,
        start + gap / 2,
        math.max(0.001, sweep - gap),
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.butt
          ..color = s.color,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.slices != slices || old.progress != progress;
}
