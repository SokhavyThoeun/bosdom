import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../co_buying/models/co_buy_session.dart';
import 'co_buy_card.dart';

/// How many times the deal list repeats to fake an infinite forward loop.
/// Large enough that auto-scrolling never visibly hits the end.
const _kLoopMultiplier = 5000;

class CoBuyCarousel extends StatefulWidget {
  const CoBuyCarousel({super.key, required this.sessions});

  final List<CoBuySession> sessions;

  @override
  State<CoBuyCarousel> createState() => _CoBuyCarouselState();
}

class _CoBuyCarouselState extends State<CoBuyCarousel> {
  final _controller = PageController();
  final _measureKey = GlobalKey();
  Timer? _timer;
  double? _height;

  @override
  void initState() {
    super.initState();
    if (widget.sessions.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _advance());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final size = _measureKey.currentContext?.size;
    if (size != null && size.height != _height) {
      setState(() => _height = size.height);
    }
  }

  void _advance() {
    if (!_controller.hasClients) return;
    _controller.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loop = widget.sessions.length > 1;
    return Stack(
      children: [
        // Offstage clone used only to measure the natural card height.
        Offstage(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CoBuyCard(
              key: _measureKey,
              session: widget.sessions.first,
              onTap: () {},
            ),
          ),
        ),
        SizedBox(
          height: _height ?? 0,
          child: PageView.builder(
            controller: _controller,
            itemCount: loop
                ? widget.sessions.length * _kLoopMultiplier
                : widget.sessions.length,
            itemBuilder: (context, index) {
              final session = widget.sessions[index % widget.sessions.length];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CoBuyCard(
                  session: session,
                  onTap: () => context.pushNamed(
                    'coBuyDetail',
                    pathParameters: {'id': session.id},
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
