import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/adaptive_network_image.dart';
import '../../cart/providers/cart_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../models/product.dart';

class ProductListTile extends ConsumerWidget {
  const ProductListTile({
    super.key,
    required this.product,
    required this.id,
    required this.onTap,
  });

  final Product product;

  /// [product]'s id, used to key the wishlist entry and to identify this
  /// product across screens.
  final String id;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final wishlistId = productWishlistId(id);
    final isFavorite = ref.watch(
      wishlistProvider.select(
        (ids) => ids.value?.contains(wishlistId) ?? false,
      ),
    );

    Future<void> addToCart() async {
      final succeeded = await ref.read(cartProvider.notifier).addItems([
        (product, product.moqValue),
      ]);
      if (!context.mounted) return;
      final message = succeeded
          ? l10n.wishlistAddedToCartSnackbar(product.name)
          : l10n.cartUpdateErrorSnackbar;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> toggleWishlist() async {
      final wasFavorite = isFavorite;
      final succeeded = await ref
          .read(wishlistProvider.notifier)
          .toggle(wishlistId);
      if (!context.mounted) return;
      final message = !succeeded
          ? l10n.wishlistToggleErrorSnackbar
          : wasFavorite
          ? l10n.wishlistRemovedFromWishlistSnackbar(product.name)
          : l10n.wishlistAddedToWishlistSnackbar(product.name);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Container(
            // Minimum height so short cards match tall ones; taller text
            // (2-line titles) may still grow the card instead of overflowing.
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  // Border painted above the image so photo edges never
                  // bleed over it or leave ragged corners.
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.6),
                    ),
                  ),
                  child: AdaptiveNetworkImage(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : Icon(
                            product.icon,
                            color: colorScheme.primary,
                            size: 30,
                          ),
                    errorBuilder: (context, error, stackTrace) => Icon(
                      product.icon,
                      color: colorScheme.primary,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatPrice(ref, product.priceValue),
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.moq,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            size: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              product.seller,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Reserve space on the right so text never sits under the
                // favorite/cart badges anchored to the card's corners.
                const SizedBox(width: 40),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _CircleIconButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              iconColor: colorScheme.primary,
              backgroundColor: Colors.white,
              shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
              size: 32,
              iconSize: 16,
              onTap: toggleWishlist,
            ),
          ),
          Positioned(
            bottom: 6,
            right: 6,
            child: _CircleIconButton(
              icon: Icons.add_shopping_cart_rounded,
              iconColor: Colors.white,
              backgroundColor: colorScheme.primary,
              shadowColor: colorScheme.primary.withValues(alpha: 0.45),
              size: 32,
              iconSize: 16,
              onTap: addToCart,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.shadowColor,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color shadowColor;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ),
      ),
    );
  }
}
