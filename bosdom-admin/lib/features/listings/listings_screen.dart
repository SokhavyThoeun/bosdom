import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;

import '../../core/api/admin_api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/models/admin_models.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/admin_shell.dart';
import '../../shared/widgets/async_loader.dart';
import '../../shared/widgets/confirm_action.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/status_pill.dart';

/// Same categories the shopper app lets sellers pick from — kept in sync
/// manually since this is a separate Flutter project from bosdom/.
/// See bosdom/lib/features/marketplace/models/category.dart.
const _kCategories = [
  'Electronics',
  'Clothing',
  'Food & Bev',
  'Beauty',
  'Home',
];

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _activeOnly = false;
  String? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: r'$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminPageHeader(
          title: 'Listings',
          subtitle: 'Every product listed across all sellers',
          actions: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ToolbarToggle(
                  label: 'Live only',
                  selected: _activeOnly,
                  onChanged: (value) => setState(() => _activeOnly = value),
                ),
                const SizedBox(width: 10),
                _ToolbarDropdown(
                  value: _category,
                  hint: 'All categories',
                  items: _kCategories,
                  onChanged: (value) => setState(() => _category = value),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 260,
                  height: 44,
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: const InputDecoration(
                      hintText: 'Search listings...',
                      hintStyle: TextStyle(fontSize: 13.5),
                      prefixIcon: Icon(Icons.search, size: 19),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) =>
                        setState(() => _query = value.trim().toLowerCase()),
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: AsyncLoader<List<AdminListing>>(
            loader: AdminApiClient.fetchListings,
            builder: (context, listings, reload) {
              var filtered = listings;
              if (_activeOnly) {
                filtered = filtered.where((l) => l.active).toList();
              }
              if (_category != null) {
                filtered = filtered
                    .where((l) => l.category == _category)
                    .toList();
              }
              if (_query.isNotEmpty) {
                filtered = filtered
                    .where(
                      (l) =>
                          l.productName.toLowerCase().contains(_query) ||
                          l.sellerName.toLowerCase().contains(_query) ||
                          l.category.toLowerCase().contains(_query),
                    )
                    .toList();
              }

              if (filtered.isEmpty) {
                return const EmptyState(message: 'No listings found.');
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth,
                          ),
                          child: DataTable(
                            dataRowMinHeight: 56,
                            dataRowMaxHeight: double.infinity,
                            columns: const [
                              DataColumn(label: Text('PRODUCT')),
                              DataColumn(label: Text('SELLER')),
                              DataColumn(label: Text('CATEGORY')),
                              DataColumn(label: Text('PRICE')),
                              DataColumn(label: Text('STOCK')),
                              DataColumn(label: Text('STATUS')),
                              DataColumn(label: Text('LISTED')),
                              DataColumn(label: Text('ACTIONS')),
                            ],
                            rows: [
                              for (final listing in filtered)
                                DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width: 280,
                                        child: Row(
                                          children: [
                                            _ProductThumbnail(
                                              photoUrls: listing.photoUrls,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                listing.productName,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(listing.sellerName)),
                                    DataCell(Text(listing.category)),
                                    DataCell(
                                      Text(currency.format(listing.price)),
                                    ),
                                    DataCell(Text('${listing.stockQty}')),
                                    DataCell(
                                      StatusPill.listing(listing.active),
                                    ),
                                    DataCell(
                                      Text(
                                        DateFormat.yMMMd().format(
                                          listing.createdAt,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: listing.active
                                              ? const Color(0xFFB3261E)
                                              : AppColors.trustGreen,
                                        ),
                                        onPressed: () => confirmAndRun(
                                          context,
                                          title: listing.active
                                              ? 'Take down listing?'
                                              : 'Restore listing?',
                                          message: listing.active
                                              ? '"${listing.productName}" will be hidden from the marketplace immediately.'
                                              : '"${listing.productName}" will be visible in the marketplace again.',
                                          confirmLabel: listing.active
                                              ? 'Take down'
                                              : 'Restore',
                                          destructive: listing.active,
                                          action: () => listing.active
                                              ? AdminApiClient.takedownListing(
                                                  listing.id,
                                                )
                                              : AdminApiClient.restoreListing(
                                                  listing.id,
                                                ),
                                          onSuccess: reload,
                                        ),
                                        child: Text(
                                          listing.active
                                              ? 'Take down'
                                              : 'Restore',
                                        ),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A pill-shaped toggle styled to match [_ToolbarDropdown] and the search
/// field's input decoration, so the header's filter controls read as one
/// toolbar instead of three mismatched widgets.
class _ToolbarToggle extends StatelessWidget {
  const _ToolbarToggle({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.blushSurface : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onChanged(!selected),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.brandCrimson : AppColors.roseDivider,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 17,
                color: selected ? AppColors.brandCrimson : AppColors.warmTaupe,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.deepBurgundy
                      : AppColors.warmBlack,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarDropdown extends StatelessWidget {
  const _ToolbarDropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.roseDivider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 13.5)),
          icon: const Icon(
            Icons.expand_more,
            size: 18,
            color: AppColors.warmTaupe,
          ),
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.warmBlack,
          ),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(hint)),
            for (final item in items)
              DropdownMenuItem<String?>(value: item, child: Text(item)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.photoUrls});

  final List<String> photoUrls;

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.warmTaupe.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 18,
          color: AppColors.warmTaupe,
        ),
      );
    }
    final url = ApiConfig.mediaUrl(photoUrls.first);
    return InkWell(
      onTap: () => web.window.open(url, '_blank'),
      borderRadius: BorderRadius.circular(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(url, width: 40, height: 40, fit: BoxFit.cover),
      ),
    );
  }
}
