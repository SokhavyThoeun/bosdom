import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/models/variant_option.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/adaptive_network_image.dart';
import '../../../shared/widgets/full_screen_image_viewer.dart';
import '../../../shared/widgets/live_stock_row.dart';
import '../../../shared/widgets/variant_selector.dart';
import '../../../shared/widgets/verified_badge_icon.dart';
import '../../cart/providers/cart_provider.dart';
import '../../profile/providers/shop_profile_provider.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../models/product.dart';
import '../models/sample_order.dart';
import '../providers/listings_provider.dart';
import '../providers/sample_gate_provider.dart';
import '../widgets/empty_products_notice.dart';

enum _BuyMode { wholesale, sample }

String _formatEligibleAt(DateTime dateTime) =>
    DateFormat.yMMMd().add_jm().format(dateTime.toLocal());

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(listingByIdProvider(productId));
    return productAsync.when(
      // A failed background poll keeps showing the last good data.
      skipError: true,
      data: (product) =>
          _ProductDetailBody(product: product, productId: productId),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return Scaffold(
          body: Center(
            child: EmptyProductsNotice(
              colorScheme: colorScheme,
              textTheme: textTheme,
              message: AppLocalizations.of(
                context,
              ).marketplaceProductsLoadError,
              onRetry: () => ref.invalidate(listingByIdProvider(productId)),
            ),
          ),
        );
      },
    );
  }
}

class _ProductDetailBody extends ConsumerStatefulWidget {
  const _ProductDetailBody({required this.product, required this.productId});

  final Product product;
  final String productId;

  @override
  ConsumerState<_ProductDetailBody> createState() => _ProductDetailBodyState();
}

class _ProductDetailBodyState extends ConsumerState<_ProductDetailBody> {
  _BuyMode _mode = _BuyMode.wholesale;
  late int _wholesaleQty = product.moqValue;
  int _sampleQty = 1;
  late String? _selectedSize = product.sizes.isNotEmpty
      ? product.sizes.first
      : null;
  late ProductColorOption? _selectedColor = product.colorOptions.isNotEmpty
      ? product.colorOptions.first
      : null;

  Timer? _refreshTimer;

  Product get product => widget.product;

  /// The most a buyer can order right now: what the seller has left.
  int get _maxWholesaleQty =>
      math.max(product.moqValue, product.stockQty ?? 9999);

  @override
  void initState() {
    super.initState();
    // Keep the stock count live as other buyers' payments take units off.
    if (product.isRealListing) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (mounted) ref.invalidate(listingByIdProvider(widget.productId));
      });
    }
  }

  @override
  void didUpdateWidget(covariant _ProductDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Stock dropped below what the buyer picked: pull them back down to it.
    if (_wholesaleQty > _maxWholesaleQty) _wholesaleQty = _maxWholesaleQty;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _changeWholesaleQty(int delta) {
    setState(() {
      _wholesaleQty = (_wholesaleQty + delta).clamp(
        product.moqValue,
        _maxWholesaleQty,
      );
    });
  }

  void _changeSampleQty(int delta) {
    setState(() {
      _sampleQty = (_sampleQty + delta).clamp(1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final product = this.product;
    final supportsSample =
        !product.isRealListing || product.samplePrice != null;
    final isOwner =
        product.sellerId != null &&
        product.sellerId == Supabase.instance.client.auth.currentUser?.id;
    final sampleEligibility = ref.watch(sampleGateProvider);
    final wishlistId = productWishlistId(widget.productId);
    final isFavorite = ref.watch(
      wishlistProvider.select(
        (ids) => ids.value?.contains(wishlistId) ?? false,
      ),
    );
    final cartItemCount = ref.watch(
      cartProvider.select((cart) => cart.value?.length ?? 0),
    );

    return Scaffold(
      body: Column(
        children: [
          ColoredBox(
            color: colorScheme.primaryContainer,
            child: _Header(
              product: product,
              colorScheme: colorScheme,
              textTheme: textTheme,
              isFavorite: isFavorite,
              onFavoriteToggle: () =>
                  ref.read(wishlistProvider.notifier).toggle(wishlistId),
              cartItemCount: cartItemCount,
              onCartTap: () => context.goNamed('cart'),
            ),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              // bottom: false keeps the viewport running to the physical bottom
              // edge; the inset is added to the content padding below instead.
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(listingByIdProvider(widget.productId).future),
                color: colorScheme.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ImageGallery(product: product, colorScheme: colorScheme),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          16,
                          24,
                          24 + MediaQuery.of(context).padding.bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: colorScheme.outline),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          style: textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      _StockBadge(
                                        status: product.stockStatus,
                                        colorScheme: colorScheme,
                                        textTheme: textTheme,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        formatPrice(
                                          ref,
                                          _mode == _BuyMode.wholesale
                                              ? product.priceValue
                                              : product.samplePriceValue,
                                        ),
                                        style: textTheme.headlineMedium
                                            ?.copyWith(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.productDetailPerUnit,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (formatSecondaryPrice(
                                        ref,
                                        _mode == _BuyMode.wholesale
                                            ? product.priceValue
                                            : product.samplePriceValue,
                                      )
                                      case final secondary?) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      secondary,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Divider(
                                    height: 1,
                                    color: colorScheme.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 16,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        l10n.productDetailMoqLabel(
                                          '${product.moqValue}',
                                        ),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (product.stockQty case final stock?) ...[
                                    const SizedBox(height: 8),
                                    LiveStockRow(
                                      stock: stock,
                                      label: l10n.productDetailStockLabel(
                                        NumberFormat.decimalPattern().format(
                                          stock,
                                        ),
                                      ),
                                      colorScheme: colorScheme,
                                      textTheme: textTheme,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (product.hasVariants) ...[
                              const SizedBox(height: 20),
                              ProductVariantSelector(
                                sizes: product.sizes,
                                selectedSize: _selectedSize,
                                onSizeSelected: (size) =>
                                    setState(() => _selectedSize = size),
                                colorOptions: product.colorOptions,
                                selectedColor: _selectedColor,
                                onColorSelected: (color) =>
                                    setState(() => _selectedColor = color),
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              ),
                            ],
                            const SizedBox(height: 20),
                            Text(
                              l10n.productDetailSpecsTitle,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _SpecsCard(
                              product: product,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                            if (supportsSample) ...[
                              const SizedBox(height: 20),
                              _ModeToggle(
                                mode: _mode,
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                                onChanged: (mode) =>
                                    setState(() => _mode = mode),
                              ),
                            ],
                            const SizedBox(height: 16),
                            _BuyBox(
                              product: product,
                              productId: widget.productId,
                              mode: supportsSample ? _mode : _BuyMode.wholesale,
                              isOwner: isOwner,
                              selectedSize: _selectedSize,
                              selectedColor: _selectedColor,
                              wholesaleQty: _wholesaleQty,
                              sampleQty: _sampleQty,
                              onWholesaleQtyChanged: _changeWholesaleQty,
                              onSampleQtyChanged: _changeSampleQty,
                              sampleEligibility: sampleEligibility.value,
                              isSampleGateLoading: sampleEligibility.isLoading,
                              onAddSample: () => ref
                                  .read(cartProvider.notifier)
                                  .addSample(product),
                              onAddToCart: () => ref
                                  .read(cartProvider.notifier)
                                  .addItems([(product, _wholesaleQty)]),
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

class _Header extends StatelessWidget {
  const _Header({
    required this.product,
    required this.colorScheme,
    required this.textTheme,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.cartItemCount,
    required this.onCartTap,
  });

  final Product product;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final int cartItemCount;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 10,
          24,
          14,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: _kHeaderContentHeight),
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
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: colorScheme.onPrimary.withValues(alpha: 0.15),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onCartTap,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: colorScheme.onPrimary,
                              size: 20,
                            ),
                            if (cartItemCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colorScheme.tertiary,
                                    shape: cartItemCount < 10
                                        ? BoxShape.circle
                                        : BoxShape.rectangle,
                                    borderRadius: cartItemCount < 10
                                        ? null
                                        : BorderRadius.circular(8),
                                    border: Border.all(
                                      color: colorScheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    cartItemCount > 99
                                        ? '99+'
                                        : '$cartItemCount',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onTertiary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _SellerRow(
                product: product,
                colorScheme: colorScheme,
                textTheme: textTheme,
                light: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageGallery extends StatefulWidget {
  const _ImageGallery({required this.product, required this.colorScheme});

  final Product product;
  final ColorScheme colorScheme;

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  static const _autoScrollInterval = Duration(seconds: 3);
  // How many times the image list repeats to fake an infinite, one-way loop.
  // Large enough that auto-scrolling never visibly hits the end.
  static const _loopMultiplier = 5000;

  late final List<String> _imageUrls = widget.product.imageUrls;
  int get _imageCount => _imageUrls.length;
  // A single photo has nothing to swipe to, so it doesn't loop or scroll.
  bool get _hasMany => _imageCount > 1;

  late final int _initialRawPage = _hasMany
      ? (_loopMultiplier ~/ 2) * _imageCount
      : 0;
  late final PageController _pageController = PageController(
    initialPage: _initialRawPage,
  );
  late int _rawPage = _initialRawPage;
  Timer? _autoScrollTimer;

  int get _selected => _rawPage % _imageCount;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    if (!_hasMany) return;
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _goTo(int targetIndex) {
    final target = _rawPage + (targetIndex - _selected);
    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.15,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _autoScrollTimer?.cancel();
              } else if (notification is ScrollEndNotification) {
                _startAutoScroll();
              }
              return false;
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _hasMany ? _imageCount * _loopMultiplier : 1,
                  onPageChanged: (index) => setState(() => _rawPage = index),
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => showFullScreenImage(
                      context,
                      imageUrls: _imageUrls,
                      initialIndex: _selected,
                      icon: widget.product.icon,
                    ),
                    child: Container(
                      color: colorScheme.primaryContainer,
                      child: AdaptiveNetworkImage(
                        _imageUrls[index % _imageCount],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : Icon(
                                widget.product.icon,
                                size: 72,
                                color: colorScheme.primary,
                              ),
                        errorBuilder: (context, error, stackTrace) => Icon(
                          widget.product.icon,
                          size: 72,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0),
                            Colors.black.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_hasMany)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_imageCount, (index) {
                        final selected = index == _selected;
                        return GestureDetector(
                          onTap: () => _goTo(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: selected ? 1 : 0.45,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_hasMany) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _imageCount,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final selected = index == _selected;
                  final borderWidth = selected ? 2.0 : 1.0;
                  return InkWell(
                    onTap: () => _goTo(index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: borderWidth,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10 - borderWidth),
                        child: AdaptiveNetworkImage(
                          _imageUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                              ? child
                              : Icon(
                                  widget.product.icon,
                                  size: 22,
                                  color: colorScheme.primary,
                                ),
                          errorBuilder: (context, error, stackTrace) => Icon(
                            widget.product.icon,
                            size: 22,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SellerRow extends ConsumerWidget {
  const _SellerRow({
    required this.product,
    required this.colorScheme,
    required this.textTheme,
    this.light = false,
  });

  final Product product;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool light;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final primaryTextColor = light ? colorScheme.onPrimary : null;
    final mutedTextColor = light
        ? colorScheme.onPrimary.withValues(alpha: 0.8)
        : colorScheme.onSurfaceVariant;
    final linkColor = light ? colorScheme.onPrimary : colorScheme.primary;
    final sellerId = product.sellerId;
    final shopProfile = sellerId == null
        ? null
        : ref.watch(shopProfileByIdProvider(sellerId)).value;
    final powerSeller = shopProfile?.highVolume ?? false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: light
                ? colorScheme.onPrimary
                : colorScheme.primaryContainer,
            child: ClipOval(
              child: Image.network(
                product.sellerLogoUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Icon(product.icon, color: colorScheme.primary, size: 26),
                errorBuilder: (context, error, stackTrace) =>
                    Icon(product.icon, color: colorScheme.primary, size: 26),
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
                      product.seller,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: primaryTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (product.verified) ...[
                    const SizedBox(width: 4),
                    const VerifiedBadgeIcon(),
                  ],
                ],
              ),
              Row(
                children: [
                  Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '${product.rating}',
                    style: textTheme.bodySmall?.copyWith(
                      color: primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (powerSeller) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.military_tech,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            l10n.storePowerSellerBadge,
                            style: textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                product.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: mutedTextColor),
              ),
              InkWell(
                onTap: () =>
                    context.pushNamed('storeProfile', extra: product.seller),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.productDetailVisitShop,
                      style: textTheme.bodySmall?.copyWith(
                        color: linkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: linkColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({
    required this.status,
    required this.colorScheme,
    required this.textTheme,
  });

  final StockStatus status;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (color, label) = switch (status) {
      StockStatus.inStock => (colorScheme.tertiary, l10n.productDetailInStock),
      StockStatus.lowStock => (colorScheme.error, l10n.productDetailLowStock),
      StockStatus.outOfStock => (
        colorScheme.primary,
        l10n.productDetailOutOfStock,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SpecsCard extends StatelessWidget {
  const _SpecsCard({
    required this.product,
    required this.colorScheme,
    required this.textTheme,
  });

  final Product product;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final specs = {
      l10n.productDetailSpecWeight: product.weight,
      l10n.productDetailSpecOrigin: product.origin,
      l10n.productDetailSpecGrade: product.grade,
      l10n.productDetailSpecPackaging: product.packaging,
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          for (final entry in specs.entries) ...[
            if (entry.key != specs.keys.first)
              Divider(height: 1, color: colorScheme.outline),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    entry.key,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    entry.value,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.mode,
    required this.colorScheme,
    required this.textTheme,
    required this.onChanged,
  });

  final _BuyMode mode;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final ValueChanged<_BuyMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeToggleButton(
              label: l10n.productDetailModeWholesale,
              selected: mode == _BuyMode.wholesale,
              colorScheme: colorScheme,
              textTheme: textTheme,
              onTap: () => onChanged(_BuyMode.wholesale),
            ),
          ),
          Expanded(
            child: _ModeToggleButton(
              label: l10n.productDetailModeSample,
              selected: mode == _BuyMode.sample,
              colorScheme: colorScheme,
              textTheme: textTheme,
              onTap: () => onChanged(_BuyMode.sample),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleButton extends StatelessWidget {
  const _ModeToggleButton({
    required this.label,
    required this.selected,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colorScheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _BuyBox extends ConsumerStatefulWidget {
  const _BuyBox({
    required this.product,
    required this.productId,
    required this.mode,
    required this.selectedSize,
    required this.selectedColor,
    required this.wholesaleQty,
    required this.sampleQty,
    required this.onWholesaleQtyChanged,
    required this.onSampleQtyChanged,
    required this.sampleEligibility,
    required this.isSampleGateLoading,
    required this.onAddSample,
    required this.onAddToCart,
    required this.colorScheme,
    required this.textTheme,
    this.isOwner = false,
  });

  final Product product;
  final String productId;
  final _BuyMode mode;
  final String? selectedSize;
  final ProductColorOption? selectedColor;
  final int wholesaleQty;
  final int sampleQty;
  final ValueChanged<int> onWholesaleQtyChanged;
  final ValueChanged<int> onSampleQtyChanged;
  final SampleEligibility? sampleEligibility;
  final bool isSampleGateLoading;
  final Future<bool> Function() onAddSample;
  final Future<bool> Function() onAddToCart;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  /// True when the signed-in user is this listing's own seller — sellers
  /// can't buy or sample their own products.
  final bool isOwner;

  @override
  ConsumerState<_BuyBox> createState() => _BuyBoxState();
}

class _BuyBoxState extends ConsumerState<_BuyBox> {
  bool _isSubmittingSample = false;
  bool _isAddingToCart = false;

  Future<void> _handleAddToCart() async {
    setState(() => _isAddingToCart = true);
    final l10n = AppLocalizations.of(context);
    final total = widget.product.priceValue * widget.wholesaleQty;
    final variantSuffix = [
      ?widget.selectedColor?.name,
      ?widget.selectedSize,
    ].join(', ');
    final succeeded = await widget.onAddToCart();
    if (!mounted) return;
    final message = succeeded
        ? l10n.productDetailAddedToCartSnackbar(formatPrice(ref, total)) +
              (variantSuffix.isEmpty ? '' : ' · $variantSuffix')
        : l10n.cartUpdateErrorSnackbar;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() => _isAddingToCart = false);
  }

  Future<void> _handleAddSample() async {
    setState(() => _isSubmittingSample = true);
    final l10n = AppLocalizations.of(context);
    final succeeded = await widget.onAddSample();
    if (!mounted) return;
    final message = succeeded
        ? l10n.productDetailSampleAddedToCartSnackbar
        : l10n.cartUpdateErrorSnackbar;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    setState(() => _isSubmittingSample = false);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final productId = widget.productId;
    final mode = widget.mode;
    final wholesaleQty = widget.wholesaleQty;
    final sampleQty = widget.sampleQty;
    final onWholesaleQtyChanged = widget.onWholesaleQtyChanged;
    final onSampleQtyChanged = widget.onSampleQtyChanged;
    final sampleEligibility = widget.sampleEligibility;
    final isSampleGateLoading = widget.isSampleGateLoading;
    final colorScheme = widget.colorScheme;
    final textTheme = widget.textTheme;
    final isOwner = widget.isOwner;
    final l10n = AppLocalizations.of(context);
    final isWholesale = mode == _BuyMode.wholesale;
    final unitPrice = isWholesale
        ? product.priceValue
        : product.samplePriceValue;
    final unitLabel = isWholesale
        ? l10n.productDetailUnitBag
        : l10n.productDetailUnitPiece;
    final quantity = isWholesale ? wholesaleQty : sampleQty;
    final total = unitPrice * quantity;
    final onCooldown = sampleEligibility != null && !sampleEligibility.eligible;
    final justRequestedThisProduct =
        onCooldown && sampleEligibility.lastSampleOrder?.listingId == productId;
    // Not enough left to fill a minimum order (or a single sample).
    final stock = product.stockQty;
    final soldOut =
        stock != null && stock < (isWholesale ? product.moqValue : 1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isWholesale
                ? l10n.productDetailWholesaleBuyTitle
                : l10n.productDetailSampleBuyTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatPrice(ref, unitPrice)} $unitLabel',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.productDetailQuantityLabel,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          _QuantityStepper(
            quantity: quantity,
            minQuantity: isWholesale ? product.moqValue : 1,
            maxQuantity: isWholesale
                ? math.max(product.moqValue, stock ?? 9999)
                : 1,
            onChanged: isWholesale ? onWholesaleQtyChanged : onSampleQtyChanged,
            disabled: isOwner || soldOut,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isOwner || soldOut
                ? null
                : isWholesale
                ? (_isAddingToCart ? null : _handleAddToCart)
                : (isSampleGateLoading || onCooldown || _isSubmittingSample)
                ? null
                : _handleAddSample,
            child: _isAddingToCart || _isSubmittingSample
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text(
                    isOwner
                        ? l10n.coBuyDetailOwnListingLabel
                        : soldOut
                        ? l10n.productDetailOutOfStock
                        : isWholesale
                        ? l10n.productDetailAddToCartButton(
                            formatPrice(ref, total),
                          )
                        : justRequestedThisProduct
                        ? l10n.productDetailSampleAlreadyRequested
                        : onCooldown
                        ? l10n.productDetailSampleCooldownActive
                        : l10n.productDetailRequestSample,
                  ),
          ),
          if (isOwner) ...[
            const SizedBox(height: 8),
            Text(
              l10n.productDetailOwnListingNote,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ] else if (!isWholesale) ...[
            const SizedBox(height: 8),
            Text(
              onCooldown
                  ? l10n.productDetailSampleCooldownNote(
                      _formatEligibleAt(sampleEligibility.eligibleAt!),
                    )
                  : l10n.productDetailSampleLimitNote,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.minQuantity,
    required this.maxQuantity,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
    this.disabled = false,
  });

  final int quantity;
  final int minQuantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepperButton(
          icon: Icons.remove,
          enabled: !disabled && quantity > minQuantity,
          onTap: () => onChanged(-1),
          colorScheme: colorScheme,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: colorScheme.outline),
                bottom: BorderSide(color: colorScheme.outline),
              ),
            ),
            child: Text(
              '$quantity',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          enabled: !disabled && quantity < maxQuantity,
          onTap: () => onChanged(1),
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.colorScheme,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? colorScheme.primary : colorScheme.outline,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: colorScheme.onPrimary, size: 18),
        ),
      ),
    );
  }
}
