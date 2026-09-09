import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../chat/providers/chat_provider.dart';
import '../models/product.dart';
import '../models/seller.dart';
import '../providers/listings_provider.dart';
import '../widgets/empty_products_notice.dart';
import '../widgets/product_list_tile.dart';

class StoreProfileScreen extends ConsumerWidget {
  const StoreProfileScreen({super.key, required this.sellerName});

  final String sellerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final listingsAsync = ref.watch(listingsProvider);

    return listingsAsync.when(
      data: (allProducts) {
        final products = allProducts
            .where((product) => product.seller == sellerName)
            .toList();
        return _StoreProfileBody(sellerName: sellerName, products: products);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: EmptyProductsNotice(
            colorScheme: colorScheme,
            textTheme: textTheme,
            message: AppLocalizations.of(context).marketplaceProductsLoadError,
            onRetry: () => ref.invalidate(listingsProvider),
          ),
        ),
      ),
    );
  }
}

class _StoreProfileBody extends StatefulWidget {
  const _StoreProfileBody({required this.sellerName, required this.products});

  final String sellerName;
  final List<Product> products;

  @override
  State<_StoreProfileBody> createState() => _StoreProfileBodyState();
}

class _StoreProfileBodyState extends State<_StoreProfileBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );
  bool _isFavorite = false;

  Seller get seller {
    if (widget.products.isEmpty) {
      return sellerFor(
        widget.sellerName,
        icon: Icons.storefront_outlined,
        rating: 4.5,
        location: 'Cambodia',
        verified: false,
      );
    }
    final sample = widget.products.first;
    return sellerFor(
      widget.sellerName,
      icon: sample.icon,
      rating: sample.rating,
      location: sample.location,
      verified: sample.verified,
    );
  }

  List<Product> get products => widget.products;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final seller = this.seller;

    return Scaffold(
      body: Column(
        children: [
          _StoreHeader(
            seller: seller,
            colorScheme: colorScheme,
            textTheme: textTheme,
            isFavorite: _isFavorite,
            onFavoriteToggle: () => setState(() => _isFavorite = !_isFavorite),
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
                    child: _StatsBar(
                      seller: seller,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                  _StoreTabBar(
                    controller: _tabController,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _ProductsTab(
                          products: products,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        _AboutTab(
                          seller: seller,
                          sellerId: products.isEmpty
                              ? null
                              : products.first.sellerId,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        _ReviewsTab(
                          seller: seller,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                      ],
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
// overall size even though it shows a back row + seller info.
const _kHeaderContentHeight = 96.0;

class _StoreHeader extends StatelessWidget {
  const _StoreHeader({
    required this.seller,
    required this.colorScheme,
    required this.textTheme,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final Seller seller;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
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
              Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Icon(
                        Icons.arrow_back,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: colorScheme.onPrimary.withValues(alpha: 0.15),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onFavoriteToggle,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.onPrimary,
                    child: ClipOval(
                      child: Image.network(
                        seller.logoUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : Icon(
                                seller.icon,
                                color: colorScheme.primary,
                                size: 22,
                              ),
                        errorBuilder: (context, error, stackTrace) => Icon(
                          seller.icon,
                          color: colorScheme.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                seller.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (seller.verified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: Colors.lightGreenAccent,
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${seller.rating}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          seller.location,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.seller,
    required this.colorScheme,
    required this.textTheme,
  });

  final Seller seller;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF9B2C2C), Color(0xFFD32F2F)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _StatItem(
            value: '${seller.productsCount}',
            label: l10n.storeProfileStatProducts,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          _StatDivider(colorScheme: colorScheme),
          _StatItem(
            value: seller.ordersCount,
            label: l10n.storeProfileStatOrders,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          _StatDivider(colorScheme: colorScheme),
          _StatItem(
            value: '${seller.rating}',
            label: l10n.storeProfileStatRating,
            icon: Icons.star,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
    this.icon,
  });

  final String value;
  final String label;
  final IconData? icon;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Colors.amber.shade400),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onInverseSurface.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: colorScheme.onInverseSurface.withValues(alpha: 0.2),
    );
  }
}

class _StoreTabBar extends StatelessWidget {
  const _StoreTabBar({
    required this.controller,
    required this.colorScheme,
    required this.textTheme,
  });

  final TabController controller;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colorScheme.outline)),
      ),
      child: TabBar(
        controller: controller,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: textTheme.bodyMedium,
        indicatorColor: colorScheme.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: l10n.storeProfileTabProducts),
          Tab(text: l10n.storeProfileTabAbout),
          Tab(text: l10n.storeProfileTabReviews),
        ],
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab({
    required this.products,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<Product> products;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (products.isEmpty) {
      return Center(
        child: Text(
          l10n.storeProfileNoProducts,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8 + MediaQuery.of(context).padding.bottom,
      ),
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
    );
  }
}

class _AboutTab extends ConsumerWidget {
  const _AboutTab({
    required this.seller,
    required this.sellerId,
    required this.colorScheme,
    required this.textTheme,
  });

  final Seller seller;

  /// Real backend user id of the seller, if any of their listings loaded —
  /// `null` means there's no real counterpart to start a chat with.
  final String? sellerId;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        _SectionCard(
          colorScheme: colorScheme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.storeProfileAboutSectionTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                seller.about,
                style: textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          colorScheme: colorScheme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.storeProfileBusinessDetailsTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.storefront_outlined,
                label: l10n.storeProfileLabelBusinessType,
                value: seller.businessType,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: l10n.storeProfileLabelYearEstablished,
                value: seller.yearEstablished,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: l10n.storeProfileLabelLocation,
                value: seller.location,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              _DetailRow(
                icon: Icons.sell_outlined,
                label: l10n.storeProfileLabelMinimumOrder,
                value: seller.minimumOrder,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              _DetailRow(
                icon: Icons.schedule_outlined,
                label: l10n.storeProfileLabelResponseTime,
                value: seller.responseTime,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              _DetailRow(
                icon: Icons.local_shipping_outlined,
                label: l10n.storeProfileLabelShipping,
                value: seller.shipping,
                colorScheme: colorScheme,
                textTheme: textTheme,
                isLast: true,
              ),
            ],
          ),
        ),
        if (seller.certifications.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionCard(
            colorScheme: colorScheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.storeProfileCertificationsTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final cert in seller.certifications)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: colorScheme.primary,
                              child: Icon(
                                cert.icon,
                                size: 14,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cert.label,
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
        if (seller.highlights.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionCard(
            colorScheme: colorScheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.storeProfileWhyChooseUsTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (final highlight in seller.highlights) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: colorScheme.primary,
                          child: Icon(
                            highlight.icon,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                highlight.title,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                highlight.description,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        if (sellerId != null) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              try {
                final conversation = await ref
                    .read(chatProvider.notifier)
                    .startConversation(counterpartId: sellerId!);
                if (!context.mounted) return;
                context.pushNamed(
                  'chatDetail',
                  pathParameters: {'id': conversation.id},
                );
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.chatStartConversationError)),
                );
              }
            },
            child: Text(l10n.storeProfileContactSupplierButton),
          ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.colorScheme, required this.child});

  final ColorScheme colorScheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12, top: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colorScheme.outline)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: colorScheme.primary,
            child: Icon(icon, size: 14, color: colorScheme.onPrimary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  const _ReviewsTab({
    required this.seller,
    required this.colorScheme,
    required this.textTheme,
  });

  final Seller seller;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (seller.rating <= 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.reviews_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.storeProfileNoReviewsTitle,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.storeProfileNoReviewsBody(seller.name),
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalBreakdown = seller.ratingBreakdown.values.fold<int>(
      0,
      (a, b) => a + b,
    );
    final hasStats = seller.recommendPercent > 0 || seller.reviewsCount != '0';
    final hasReviews = seller.reviews.isNotEmpty;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        _SectionCard(
          colorScheme: colorScheme,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    seller.rating.toStringAsFixed(1),
                    style: textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StarRow(rating: seller.rating, size: 20),
                  if (seller.reviewsCount != '0') ...[
                    const SizedBox(width: 10),
                    Text(
                      l10n.storeProfileReviewsCount(seller.reviewsCount),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
              if (hasStats) ...[
                const SizedBox(height: 16),
                Divider(color: colorScheme.outline),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ReviewStatChip(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      icon: Icons.thumb_up_outlined,
                      label: l10n.storeProfileRecommendPercent(
                        '${seller.recommendPercent}',
                      ),
                    ),
                    _ReviewStatChip(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      icon: Icons.schedule_outlined,
                      label: l10n.storeProfileResponseTimeChip(
                        seller.responseTime.replaceFirst('Within ', ''),
                      ),
                    ),
                    _ReviewStatChip(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      icon: Icons.military_tech_outlined,
                      label: l10n.storeProfileTopSellerChip,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (totalBreakdown > 0) ...[
          const SizedBox(height: 16),
          _SectionCard(
            colorScheme: colorScheme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.storeProfileRatingBreakdownTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                for (var star = 5; star >= 1; star--)
                  _RatingBreakdownRow(
                    star: star,
                    percent: seller.ratingBreakdown[star] ?? 0,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    isLast: star == 1,
                  ),
              ],
            ),
          ),
        ],
        if (hasReviews) ...[
          const SizedBox(height: 16),
          Text(
            l10n.storeProfileRecentReviewsTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final review in seller.reviews) ...[
            _ReviewCard(
              review: review,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < filled ? Icons.star : Icons.star_border,
            size: size,
            color: Colors.amber.shade700,
          ),
      ],
    );
  }
}

class _ReviewStatChip extends StatelessWidget {
  const _ReviewStatChip({
    required this.colorScheme,
    required this.textTheme,
    required this.icon,
    required this.label,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _RatingBreakdownRow extends StatelessWidget {
  const _RatingBreakdownRow({
    required this.star,
    required this.percent,
    required this.colorScheme,
    required this.textTheme,
    this.isLast = false,
  });

  final int star;
  final int percent;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$star', style: textTheme.bodySmall),
                const SizedBox(width: 4),
                _StarRow(rating: star.toDouble(), size: 14),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$percent%',
              textAlign: TextAlign.right,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.colorScheme,
    required this.textTheme,
  });

  final SellerReview review;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colorScheme.primary,
                child: Text(
                  review.reviewerName.isNotEmpty
                      ? review.reviewerName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewerName,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      review.date,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _StarRow(rating: review.rating.toDouble(), size: 14),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
