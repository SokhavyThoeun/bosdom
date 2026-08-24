import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../marketplace/models/product.dart';

class WishlistItemCard extends StatefulWidget {
  const WishlistItemCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onRemove,
    required this.onAddToCart,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;

  @override
  State<WishlistItemCard> createState() => _WishlistItemCardState();
}

class _WishlistItemCardState extends State<WishlistItemCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _exitController;
  bool _removing = false;

  @override
  void initState() {
    super.initState();
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
  }

  @override
  void dispose() {
    _exitController.dispose();
    super.dispose();
  }

  Future<void> _handleRemove() async {
    if (_removing) return;
    setState(() => _removing = true);
    await _exitController.forward();
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final product = widget.product;

    final fade = CurvedAnimation(
      parent: _exitController,
      curve: const Interval(0, 0.7, curve: Curves.easeIn),
    );
    final collapse = CurvedAnimation(
      parent: _exitController,
      curve: const Interval(0.2, 1, curve: Curves.easeInOut),
    );

    return SizeTransition(
      sizeFactor: Tween<double>(begin: 1, end: 0).animate(collapse),
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(fade),
        child: ScaleTransition(
          scale: Tween<double>(begin: 1, end: 0.88).animate(fade),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 6),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            product.icon,
                            color: colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        Positioned(
                          top: -10,
                          right: -10,
                          child: _WishlistHeartButton(
                            onTap: _handleRemove,
                            colorScheme: colorScheme,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.price,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.moq,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            FilledButton(
                              onPressed: widget.onAddToCart,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                textStyle: textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: Text(l10n.wishlistAddToCartButton),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The wishlist heart toggle: a filled heart badge that pops with a quick
/// bounce when tapped, then hands off to the card's shrink/fade-out exit.
class _WishlistHeartButton extends StatefulWidget {
  const _WishlistHeartButton({required this.onTap, required this.colorScheme});

  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  State<_WishlistHeartButton> createState() => _WishlistHeartButtonState();
}

class _WishlistHeartButtonState extends State<_WishlistHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _popController;
  bool _tapped = false;

  @override
  void initState() {
    super.initState();
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _popController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_tapped) return;
    setState(() => _tapped = true);
    await _popController.forward();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.35,
          end: 0.8,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.8,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
    ]).animate(_popController);

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: scale,
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.favorite,
            color: widget.colorScheme.primary,
            size: 15,
          ),
        ),
      ),
    );
  }
}
