import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../cart/providers/cart_provider.dart';
import '../../marketplace/models/product.dart';
import '../../marketplace/widgets/empty_products_notice.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/wishlist_item_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  Future<void> _addToCart(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final l10n = AppLocalizations.of(context);
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final productsAsync = ref.watch(wishlistProductsProvider);

    return Scaffold(
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: productsAsync.when(
                data: (products) => products.isEmpty
                    ? _EmptyState(
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      )
                    : ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          24,
                          24,
                          8 + MediaQuery.of(context).padding.bottom,
                        ),
                        itemCount: products.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 16),
                        itemBuilder: (context, i) {
                          final product = products[i];
                          return WishlistItemCard(
                            product: product,
                            onTap: () => context.pushNamed(
                              'productDetail',
                              pathParameters: {'id': product.id},
                            ),
                            onRemove: () => ref
                                .read(wishlistProvider.notifier)
                                .toggle(productWishlistId(product.id)),
                            onAddToCart: () =>
                                _addToCart(context, ref, product),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: EmptyProductsNotice(
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    message: l10n.wishlistLoadErrorMessage,
                    onRetry: () => ref.invalidate(wishlistProductsProvider),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Sized to fit just a centered title, shorter than the two-row
// home/search header since there's no back row or search bar to fit.
const _kHeaderContentHeight = 48.0;

class _Header extends StatelessWidget {
  const _Header({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 10,
          24,
          14,
        ),
        child: SizedBox(
          height: _kHeaderContentHeight,
          child: Center(
            child: Text(
              l10n.wishlistScreenTitle,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.wishlistEmptyStateMessage,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
