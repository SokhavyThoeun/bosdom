import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../marketplace/models/category.dart';
import '../../marketplace/models/product.dart';
import '../../marketplace/providers/listings_provider.dart';
import '../../marketplace/widgets/category_item.dart';
import '../../marketplace/widgets/empty_products_notice.dart';
import '../../marketplace/widgets/product_list_tile.dart';

const _kTrendingSearches = [
  'Jasmine Rice',
  'Paper Hot Cups',
  'Tote Bags',
  'Earbuds Bulk',
  'Snack Mix',
];

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  bool _recentExpanded = false;
  final List<String> _recentSearches = [
    'Wholesale T-Shirts',
    'USB-C Charger',
    'Coconut Oil',
    'Kitchen Towel Rolls',
    'Wireless Earbuds',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Product> _results(List<Product> products) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return const [];
    final terms = query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    return products.where((product) {
      final haystack = '${product.name} ${product.seller}'.toLowerCase();
      return terms.every(haystack.contains);
    }).toList();
  }

  void _submitSearch(String value) {
    final term = value.trim();
    if (term.isEmpty) return;
    setState(() {
      _query = term;
      _recentSearches.remove(term);
      _recentSearches.insert(0, term);
      if (_recentSearches.length > 6) {
        _recentSearches.removeLast();
      }
    });
  }

  void _applySearch(String term) {
    _controller.text = term;
    _submitSearch(term);
  }

  void _clearSearch() {
    _controller.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isSearching = _query.trim().isNotEmpty;
    final listingsAsync = ref.watch(listingsProvider);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Column(
          children: [
            _Header(
              controller: _controller,
              colorScheme: colorScheme,
              textTheme: textTheme,
              hasQuery: isSearching,
              onChanged: (value) => setState(() => _query = value),
              onSubmitted: _submitSearch,
              onClear: _clearSearch,
            ),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: isSearching
                    ? _SearchResults(
                        query: _query,
                        results: listingsAsync.when(
                          data: _results,
                          loading: () => null,
                          error: (_, _) => const [],
                        ),
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      )
                    : _SearchSuggestions(
                        recentSearches: _recentSearches,
                        recentExpanded: _recentExpanded,
                        onToggleRecentExpanded: () =>
                            setState(() => _recentExpanded = !_recentExpanded),
                        onRecentTap: _applySearch,
                        onClearAll: () => setState(() {
                          _recentSearches.clear();
                          _recentExpanded = false;
                        }),
                        onTrendingTap: _applySearch,
                        onCategoryTap: (category) => context.pushNamed(
                          'categoryResults',
                          extra: category,
                        ),
                        recommended: listingsAsync,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Matches the combined height of the logo/notification row + search bar
// used by the homepage and wishlist headers, so this header is the same
// overall size even though it shows a title + search field.
const _kHeaderContentHeight = 96.0;

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.colorScheme,
    required this.textTheme,
    required this.hasQuery,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 16,
          24,
          20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _kHeaderContentHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.searchScreenTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                          textInputAction: TextInputAction.search,
                          textAlignVertical: TextAlignVertical.center,
                          style: textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: l10n.searchHint,
                            hintStyle: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            isDense: true,
                            isCollapsed: true,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (hasQuery)
                        InkWell(
                          onTap: onClear,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.close,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _kCollapsedRecentSearchCount = 3;

class _SearchSuggestions extends StatelessWidget {
  const _SearchSuggestions({
    required this.recentSearches,
    required this.recentExpanded,
    required this.onToggleRecentExpanded,
    required this.onRecentTap,
    required this.onClearAll,
    required this.onTrendingTap,
    required this.onCategoryTap,
    required this.recommended,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<String> recentSearches;
  final bool recentExpanded;
  final VoidCallback onToggleRecentExpanded;
  final ValueChanged<String> onRecentTap;
  final VoidCallback onClearAll;
  final ValueChanged<String> onTrendingTap;
  final ValueChanged<Category> onCategoryTap;
  final AsyncValue<List<Product>> recommended;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (recentSearches.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  l10n.searchRecentSearchesTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClearAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.searchClearAll,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        (recentExpanded
                                ? recentSearches
                                : recentSearches.take(
                                    _kCollapsedRecentSearchCount,
                                  ))
                            .map(
                              (term) => _SearchChip(
                                label: term,
                                icon: Icons.access_time,
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                                onTap: () => onRecentTap(term),
                              ),
                            )
                            .toList(),
                  ),
                ),
                if (recentSearches.length > _kCollapsedRecentSearchCount) ...[
                  const SizedBox(width: 10),
                  _RecentSearchExpandButton(
                    expanded: recentExpanded,
                    colorScheme: colorScheme,
                    onTap: onToggleRecentExpanded,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
          ],
          Text(
            l10n.searchTrendingSearchesTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              for (var i = 0; i < _kTrendingSearches.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _SearchChip(
                        label: _kTrendingSearches[i],
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        onTap: () => onTrendingTap(_kTrendingSearches[i]),
                        centered: true,
                      ),
                    ),
                    if (i + 1 < _kTrendingSearches.length) ...[
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SearchChip(
                          label: _kTrendingSearches[i + 1],
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          onTap: () => onTrendingTap(_kTrendingSearches[i + 1]),
                          centered: true,
                        ),
                      ),
                    ] else
                      const Spacer(),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.searchSuggestedCategoriesTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kCategories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 16),
              itemBuilder: (context, index) => CategoryItem(
                category: kCategories[index],
                onTap: () => onCategoryTap(kCategories[index]),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.searchRecommendedForYouTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          recommended.when(
            data: (products) => products.isEmpty
                ? EmptyProductsNotice(
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    message: l10n.marketplaceNoProductsYet,
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductListTile(
                        product: product,
                        id: product.id,
                        onTap: () => context.pushNamed(
                          'productDetail',
                          pathParameters: {'id': product.id},
                        ),
                      );
                    },
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stackTrace) => EmptyProductsNotice(
              colorScheme: colorScheme,
              textTheme: textTheme,
              message: l10n.marketplaceProductsLoadError,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip({
    required this.label,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
    this.icon,
    this.iconColor,
    this.centered = false,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: centered ? double.infinity : null,
          alignment: centered ? Alignment.center : null,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: iconColor ?? colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSearchExpandButton extends StatelessWidget {
  const _RecentSearchExpandButton({
    required this.expanded,
    required this.colorScheme,
    required this.onTap,
  });

  final bool expanded;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.outline),
          ),
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: expanded ? 0.5 : 0,
            child: Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.results,
    required this.colorScheme,
    required this.textTheme,
  });

  final String query;

  /// `null` while listings are still loading.
  final List<Product>? results;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = this.results;
    if (results == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.searchNoResults(query),
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

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = results[index];
        return ProductListTile(
          product: product,
          id: product.id,
          onTap: () => context.pushNamed(
            'productDetail',
            pathParameters: {'id': product.id},
          ),
        );
      },
    );
  }
}
