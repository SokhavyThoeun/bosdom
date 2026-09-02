import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../marketplace/models/product.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/wishlist_item_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  void _addToCart(BuildContext context, Product product) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.wishlistAddedToCartSnackbar(product.name))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final wishlistIds = ref.watch(wishlistProvider).value ?? const {};

    final indices = [
      for (var index = 0; index < kMockProducts.length; index++)
        if (wishlistIds.contains(productWishlistId('$index'))) index,
    ];

    return Scaffold(
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: indices.isEmpty
                  ? _EmptyState(colorScheme: colorScheme, textTheme: textTheme)
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        24,
                        24,
                        8 + MediaQuery.of(context).padding.bottom,
                      ),
                      itemCount: indices.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (context, i) {
                        final index = indices[i];
                        final product = kMockProducts[index];
                        return WishlistItemCard(
                          product: product,
                          onTap: () => context.pushNamed(
                            'productDetail',
                            pathParameters: {'id': '$index'},
                          ),
                          onRemove: () => ref
                              .read(wishlistProvider.notifier)
                              .toggle(productWishlistId('$index')),
                          onAddToCart: () => _addToCart(context, product),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Matches the combined height of the logo/notification row + search bar
// used by the homepage and search headers, so this header is the same
// overall size even though it only shows a centered title.
const _kHeaderContentHeight = 96.0;

class _Header extends StatelessWidget {
  const _Header({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 16,
          24,
          20,
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
