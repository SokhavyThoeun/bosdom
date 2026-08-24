import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/product_list_tile.dart';

class CategoryResultsScreen extends StatefulWidget {
  const CategoryResultsScreen({super.key, required this.category});

  final Category category;

  @override
  State<CategoryResultsScreen> createState() => _CategoryResultsScreenState();
}

class _CategoryResultsScreenState extends State<CategoryResultsScreen> {
  final _controller = TextEditingController();
  final Set<String> _selectedCategories = {};
  bool _isGridView = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedCategories.add(widget.category.label);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Product> get _results {
    final query = _query.trim().toLowerCase();
    return kMockProducts.where((product) {
      final matchesCategory =
          _selectedCategories.isEmpty ||
          _selectedCategories.contains(product.category);
      final matchesQuery =
          query.isEmpty || product.name.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _removeCategory(String label) {
    setState(() => _selectedCategories.remove(label));
  }

  Future<void> _openFilters() async {
    final applied = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _FilterSheet(initialSelection: _selectedCategories),
    );
    if (applied != null) {
      setState(() {
        _selectedCategories
          ..clear()
          ..addAll(applied);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final results = _results;

    return Scaffold(
      body: Column(
        children: [
          _Header(
            controller: _controller,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onChanged: (value) => setState(() => _query = value),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterButton(
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            onTap: _openFilters,
                          ),
                          const SizedBox(width: 10),
                          for (final label in _selectedCategories) ...[
                            _SelectedChip(
                              label: label,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                              onRemove: () => _removeCategory(label),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        Text(
                          l10n.categoryResultsItemsCount('${results.length}'),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () =>
                              setState(() => _isGridView = !_isGridView),
                          icon: Icon(
                            _isGridView ? Icons.grid_view_rounded : Icons.view_list_rounded,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: results.isEmpty
                        ? Center(
                            child: Text(
                              l10n.categoryResultsNoProducts,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : _isGridView
                        ? GridView.builder(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              0,
                              24,
                              8 + MediaQuery.of(context).padding.bottom,
                            ),
                            itemCount: results.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.64,
                                ),
                            itemBuilder: (context, index) {
                              final product = results[index];
                              return ProductCard(
                                product: product,
                                onTap: () => context.pushNamed(
                                  'productDetail',
                                  pathParameters: {
                                    'id': '${kMockProducts.indexOf(product)}',
                                  },
                                ),
                              );
                            },
                          )
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              0,
                              24,
                              8 + MediaQuery.of(context).padding.bottom,
                            ),
                            itemCount: results.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final product = results[index];
                              return ProductListTile(
                                product: product,
                                onTap: () => context.pushNamed(
                                  'productDetail',
                                  pathParameters: {
                                    'id': '${kMockProducts.indexOf(product)}',
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Matches the combined height of the logo/notification row + search bar
// used by the homepage and wishlist headers, so this header is the same
// overall size even though it shows a back row + search field.
const _kHeaderContentHeight = 96.0;

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.colorScheme,
    required this.textTheme,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back, color: colorScheme.onPrimary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        l10n.commonBack,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.categoryResultsSearchHint,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 24,
                    ),
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

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune_rounded, size: 16, color: colorScheme.onSurface),
              const SizedBox(width: 6),
              Text(
                l10n.categoryResultsFiltersButton,
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

class _SelectedChip extends StatelessWidget {
  const _SelectedChip({
    required this.label,
    required this.colorScheme,
    required this.textTheme,
    required this.onRemove,
  });

  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Icon(Icons.close, size: 16, color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initialSelection});

  final Set<String> initialSelection;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final Set<String> _selection = {};

  @override
  void initState() {
    super.initState();
    _selection.addAll(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  l10n.categoryResultsFilterSheetTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(_selection.clear),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l10n.categoryResultsClearAll,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final category in kCategories)
              CheckboxListTile(
                value: _selection.contains(category.label),
                onChanged: (checked) {
                  setState(() {
                    if (checked ?? false) {
                      _selection.add(category.label);
                    } else {
                      _selection.remove(category.label);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: colorScheme.primary,
                secondary: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.blushSurface,
                  child: Icon(
                    category.icon,
                    color: AppColors.brandCrimson,
                    size: 16,
                  ),
                ),
                title: Text(
                  category.label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_selection),
              child: Text(l10n.categoryResultsApplyFilters),
            ),
          ],
        ),
      ),
    );
  }
}
