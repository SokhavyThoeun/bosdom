import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

/// One tab of [FloatingNavBar].
class FloatingNavItem {
  const FloatingNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

/// Glassmorphic floating pill with a spring-driven indicator that slides to
/// the selected tab.
///
/// The widget paints only the pill itself — no surrounding surface — so the
/// host can place it over the body with `extendBody: true` and let content
/// scroll behind it.
class FloatingNavBar extends StatefulWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<FloatingNavBar> createState() => _FloatingNavBarState();
}

const double _kBarHeight = 68;
const double _kRadius = 999;
const double _kIndicatorInset = 4;

class _FloatingNavBarState extends State<FloatingNavBar>
    with SingleTickerProviderStateMixin {
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 450,
    damping: 28,
  );

  late final AnimationController _controller = AnimationController.unbounded(
    vsync: this,
    value: widget.currentIndex.toDouble(),
  );

  @override
  void didUpdateWidget(covariant FloatingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controller.animateWith(
        SpringSimulation(
          _spring,
          _controller.value,
          widget.currentIndex.toDouble(),
          _controller.velocity,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / widget.items.length;

        return ClipRRect(
          borderRadius: BorderRadius.circular(_kRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: _kBarHeight,
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(_kRadius),
                border: Border.all(
                  color: colorScheme.onPrimary.withValues(alpha: 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => Positioned(
                      left: _controller.value * itemWidth + _kIndicatorInset,
                      top: _kIndicatorInset,
                      bottom: _kIndicatorInset,
                      width: itemWidth - _kIndicatorInset * 2,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(
                              _kRadius - _kIndicatorInset,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < widget.items.length; i++)
                        Expanded(
                          child: _FloatingNavTab(
                            item: widget.items[i],
                            selected: i == widget.currentIndex,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onTap(i);
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FloatingNavTab extends StatelessWidget {
  const _FloatingNavTab({
    required this.item,
    required this.selected,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool selected;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? colorScheme.onPrimary
        : colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_kRadius - _kIndicatorInset),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.15 : 1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: Icon(
                selected ? item.activeIcon : item.icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected ? 1 : 0.7,
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
