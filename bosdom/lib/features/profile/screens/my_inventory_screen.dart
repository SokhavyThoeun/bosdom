import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/seller_listing.dart';

enum _InventoryFilter { all, active, inactive }

// Same header size/shape as the seller dashboard/orders screens so moving
// between seller screens feels like the same app.
const _kHeaderContentHeight = 96.0;

class MyInventoryScreen extends StatefulWidget {
  const MyInventoryScreen({super.key});

  @override
  State<MyInventoryScreen> createState() => _MyInventoryScreenState();
}

class _MyInventoryScreenState extends State<MyInventoryScreen> {
  final _searchController = TextEditingController();
  var _listings = kMockSellerListings;
  var _filter = _InventoryFilter.all;
  var _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SellerListing> get _filteredListings => _listings.where((listing) {
    final matchesFilter = switch (_filter) {
      _InventoryFilter.all => true,
      _InventoryFilter.active => listing.active,
      _InventoryFilter.inactive => !listing.active,
    };
    final matchesQuery = listing.name.toLowerCase().contains(
      _query.trim().toLowerCase(),
    );
    return matchesFilter && matchesQuery;
  }).toList();

  void _toggleActive(SellerListing listing) {
    final l10n = AppLocalizations.of(context);
    final activated = !listing.active;
    setState(() {
      _listings = [
        for (final item in _listings)
          if (item == listing) item.copyWith(active: activated) else item,
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          activated
              ? l10n.myInventoryListingActivatedSnackbar(listing.name)
              : l10n.myInventoryListingDeactivatedSnackbar(listing.name),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final filteredListings = _filteredListings;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: _SearchField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _FilterRow(
                      selected: _filter,
                      onSelected: (filter) =>
                          setState(() => _filter = filter),
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredListings.isEmpty
                        ? _EmptyState(colorScheme: colorScheme, textTheme: textTheme)
                        : ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              0,
                              24,
                              16 + MediaQuery.of(context).padding.bottom,
                            ),
                            itemCount: filteredListings.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final listing = filteredListings[index];
                              return _ListingCard(
                                listing: listing,
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                                onToggleActive: () => _toggleActive(listing),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('addListing'),
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

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
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.goNamed('sellerDashboard'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Icon(
                      Icons.arrow_back,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Text(
                l10n.myInventoryScreenTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.roseDivider),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.search, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                textAlignVertical: TextAlignVertical.center,
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: l10n.myInventorySearchHint,
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
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.selected,
    required this.onSelected,
    required this.colorScheme,
    required this.textTheme,
  });

  final _InventoryFilter selected;
  final ValueChanged<_InventoryFilter> onSelected;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final filters = {
      _InventoryFilter.all: l10n.myInventoryFilterAll,
      _InventoryFilter.active: l10n.myInventoryFilterActive,
      _InventoryFilter.inactive: l10n.myInventoryFilterInactive,
    };

    return Row(
      children: [
        for (final entry in filters.entries) ...[
          _FilterChip(
            label: entry.value,
            isSelected: selected == entry.key,
            onTap: () => onSelected(entry.key),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          if (entry.key != filters.keys.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? colorScheme.primary : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.listing,
    required this.colorScheme,
    required this.textTheme,
    required this.onToggleActive,
  });

  final SellerListing listing;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              listing.imageUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 56,
                height: 56,
                color: colorScheme.primaryContainer,
                alignment: Alignment.center,
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${listing.price.toStringAsFixed(2)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.brandCrimson,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.myInventoryStockLabel(listing.stockLabel),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: listing.active,
            onChanged: (_) => onToggleActive(),
            activeTrackColor: AppColors.brandCrimson,
          ),
        ],
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
              Icons.inventory_2_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myInventoryEmptyStateMessage,
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
