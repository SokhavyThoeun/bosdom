import 'package:flutter/material.dart';

/// Fades and slides [child] up on first build, after [delay] — used to
/// stagger dashboard cards so the page assembles instead of popping in.
class Reveal extends StatefulWidget {
  const Reveal({required this.child, this.delay = Duration.zero, super.key});

  final Widget child;
  final Duration delay;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    return super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _t,
    child: widget.child,
    builder: (context, child) => Opacity(
      opacity: _t.value,
      child: Transform.translate(
        offset: Offset(0, (1 - _t.value) * 18),
        child: child,
      ),
    ),
  );
}

/// Reveals [child] left-to-right, so a line/area chart looks drawn in.
class DrawIn extends StatelessWidget {
  const DrawIn({
    required this.child,
    this.duration = const Duration(milliseconds: 1100),
    super.key,
  });

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: duration,
    curve: Curves.easeOutCubic,
    child: child,
    builder: (context, v, child) =>
        ClipRect(clipper: _WidthClipper(v), child: child),
  );
}

class _WidthClipper extends CustomClipper<Rect> {
  _WidthClipper(this.factor);
  final double factor;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * factor, size.height);

  @override
  bool shouldReclip(_WidthClipper old) => old.factor != factor;
}

/// Counts a number up to [value]; [format] renders each frame.
class CountUp extends StatelessWidget {
  const CountUp({
    required this.value,
    required this.format,
    this.style,
    super.key,
  });

  final double value;
  final String Function(double) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: value),
    duration: const Duration(milliseconds: 900),
    curve: Curves.easeOutCubic,
    builder: (context, v, _) => Text(format(v), style: style),
  );
}

/// Lifts its child slightly while the pointer hovers it.
class HoverLift extends StatefulWidget {
  const HoverLift({required this.child, super.key});

  final Widget child;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _hover = true),
    onExit: (_) => setState(() => _hover = false),
    child: AnimatedSlide(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      offset: Offset(0, _hover ? -0.025 : 0),
      child: widget.child,
    ),
  );
}
