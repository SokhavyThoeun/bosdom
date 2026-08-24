import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../checkout/screens/checkout_screen.dart' show CheckoutLineItem;
import '../models/co_buy_session.dart';
import '../providers/co_buy_provider.dart';

class CoBuyDetailScreen extends ConsumerStatefulWidget {
  const CoBuyDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<CoBuyDetailScreen> createState() => _CoBuyDetailScreenState();
}

class _CoBuyDetailScreenState extends ConsumerState<CoBuyDetailScreen> {
  bool _isFavorite = false;
  int? _quantity;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final session = ref
        .watch(coBuyProvider)
        .firstWhere((s) => s.id == widget.sessionId);
    final quantity = _quantity ??= session.minOrderQty;
    final subtotal = quantity * session.price;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F7),
      body: Column(
        children: [
          ColoredBox(
            color: colorScheme.primaryContainer,
            child: _Header(
              session: session,
              colorScheme: colorScheme,
              textTheme: textTheme,
              isFavorite: _isFavorite,
              onFavoriteToggle: () =>
                  setState(() => _isFavorite = !_isFavorite),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                SafeArea(
                  top: false,
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: 96 + MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ImageBanner(
                          session: session,
                          colorScheme: colorScheme,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorScheme.outline,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          '\$${session.price.toStringAsFixed(2)}',
                                          style: textTheme.headlineMedium
                                              ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '\$${session.originalPrice.toStringAsFixed(2)}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorScheme.tertiary
                                                .withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.circle,
                                                size: 8,
                                                color: colorScheme.tertiary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                l10n.coBuyDetailActiveDealLabel,
                                                style: textTheme.labelSmall
                                                    ?.copyWith(
                                                      color:
                                                          colorScheme.tertiary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      session.perUnitLabel,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      session.productName,
                                      style: textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        height: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _ProgressCard(
                                session: session,
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              ),
                              const SizedBox(height: 20),
                              _OrderCard(
                                session: session,
                                quantity: quantity,
                                subtotal: subtotal,
                                onQuantityChanged: (delta) => setState(() {
                                  _quantity = (quantity + delta).clamp(
                                    session.minOrderQty,
                                    session.targetQty,
                                  );
                                }),
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
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                      child: _JoinCoBuyButton(
                        joined: session.joined,
                        isFull: session.isFull,
                        subtotal: subtotal,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        onTap: session.isFull
                            ? () => context.pushNamed(
                                'checkout',
                                extra: {
                                  'items': [
                                    CheckoutLineItem(
                                      icon: session.icon,
                                      name: session.productName,
                                      qtyLabel: l10n.coBuyDetailQtyLabel(
                                        quantity,
                                        session.unitLabel,
                                      ),
                                      total: subtotal,
                                    ),
                                  ],
                                },
                              )
                            : () {
                                ref
                                    .read(coBuyProvider.notifier)
                                    .toggleJoin(session.id);
                                // toggleJoin mutates the same session instance in place,
                                // so `session.joined` already reflects the post-toggle state.
                                final nowJoined = session.joined;
                                showAppSnackBar(
                                  context,
                                  type: nowJoined
                                      ? AppSnackBarType.success
                                      : AppSnackBarType.info,
                                  message: nowJoined
                                      ? l10n.coBuyDetailJoinedSnackbar(
                                          session.productName,
                                          '\$${subtotal.toStringAsFixed(2)}',
                                        )
                                      : l10n.coBuyDetailLeftSnackbar(
                                          session.productName,
                                        ),
                                );
                              },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Matches the combined height of the logo/notification row + search bar
// used by the homepage and other headers, so this header is the same
// overall size even though it shows a back row + seller info.
const _kHeaderContentHeight = 96.0;

class _Header extends StatelessWidget {
  const _Header({
    required this.session,
    required this.colorScheme,
    required this.textTheme,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final CoBuySession session;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

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
              Row(
                children: [
                  InkWell(
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.goNamed('coBuying'),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: colorScheme.onPrimary,
                            size: 20,
                          ),
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
                ],
              ),
              _SellerRow(
                session: session,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerRow extends StatelessWidget {
  const _SellerRow({
    required this.session,
    required this.colorScheme,
    required this.textTheme,
  });

  final CoBuySession session;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.onPrimary,
            child: Icon(session.icon, color: colorScheme.primary, size: 26),
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
                      session.sellerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (session.sellerVerified) ...[
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
                  Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                  const SizedBox(width: 4),
                  Text(
                    '${session.sellerRating}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                session.sellerLocation,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
              InkWell(
                onTap: () => context.pushNamed(
                  'storeProfile',
                  extra: session.sellerName,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.coBuyDetailVisitShopLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
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

class _ImageBanner extends StatefulWidget {
  const _ImageBanner({required this.session, required this.colorScheme});

  final CoBuySession session;
  final ColorScheme colorScheme;

  @override
  State<_ImageBanner> createState() => _ImageBannerState();
}

class _ImageBannerState extends State<_ImageBanner> {
  static const _dotCount = 4;
  static const _autoScrollInterval = Duration(seconds: 3);
  static const _loopMultiplier = 5000;

  late final int _initialRawPage = (_loopMultiplier ~/ 2) * _dotCount;
  late final PageController _pageController = PageController(
    initialPage: _initialRawPage,
  );
  late int _rawPage = _initialRawPage;
  Timer? _autoScrollTimer;

  int get _selected => _rawPage % _dotCount;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!_pageController.hasClients) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _goTo(int targetIndex) {
    _autoScrollTimer?.cancel();
    final target = _rawPage + (targetIndex - _selected);
    _pageController
        .animateToPage(
          target,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        )
        .then((_) => _startAutoScroll());
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

    return AspectRatio(
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
              itemCount: _dotCount * _loopMultiplier,
              onPageChanged: (index) => setState(() => _rawPage = index),
              itemBuilder: (context, index) => Container(
                color: colorScheme.primaryContainer,
                alignment: Alignment.center,
                child: Icon(
                  widget.session.icon,
                  size: 96,
                  color: colorScheme.primary,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_dotCount, (index) {
                  final selected = index == _selected;
                  return GestureDetector(
                    onTap: () => _goTo(index),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 10,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary.withValues(
                            alpha: selected ? 1 : 0.3,
                          ),
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
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.session,
    required this.colorScheme,
    required this.textTheme,
  });

  final CoBuySession session;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progressPct = (session.progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.coBuyDetailProgressTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.coBuyDetailProgressLine(
                    session.currentQty,
                    session.targetQty,
                    session.unitLabel,
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$progressPct%',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: session.progress,
              minHeight: 10,
              backgroundColor: colorScheme.primaryContainer,
              valueColor: AlwaysStoppedAnimation(colorScheme.tertiary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.circle, size: 6, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.coBuyDetailRetailersJoined(session.retailersJoined),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.schedule_rounded, size: 14, color: colorScheme.error),
              const SizedBox(width: 5),
              Text(
                session.timeLeft,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.savings_rounded,
                size: 15,
                color: colorScheme.tertiary,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.coBuyDetailYouSaveLine(
                  session.savingsPct,
                  session.perUnitLabel,
                ),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.session,
    required this.quantity,
    required this.subtotal,
    required this.onQuantityChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  final CoBuySession session;
  final int quantity;
  final double subtotal;
  final ValueChanged<int> onQuantityChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
            l10n.coBuyDetailYourOrderTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.coBuyDetailQuantityLabel,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StepperButton(
                icon: Icons.remove,
                enabled: quantity > session.minOrderQty,
                onTap: () => onQuantityChanged(-1),
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
                enabled: quantity < session.targetQty,
                onTap: () => onQuantityChanged(1),
                colorScheme: colorScheme,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.coBuyDetailMinOrderLabel(
              session.minOrderQty,
              session.unitLabel,
            ),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colorScheme.outline),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                l10n.coBuyDetailSubtotalLabel,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
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

class _JoinCoBuyButton extends StatelessWidget {
  const _JoinCoBuyButton({
    required this.joined,
    required this.isFull,
    required this.subtotal,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final bool joined;
  final bool isFull;
  final double subtotal;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Once the group hits its target, joined members check out and
    // everyone else is locked out — the button can no longer join/leave.
    final checkoutReady = isFull && joined;
    final lockedOut = isFull && !joined;

    final Color background;
    final Color foreground;
    if (checkoutReady) {
      background = colorScheme.primary;
      foreground = colorScheme.onPrimary;
    } else if (lockedOut) {
      background = colorScheme.onSurfaceVariant.withValues(alpha: 0.12);
      foreground = colorScheme.onSurfaceVariant;
    } else if (joined) {
      background = Colors.white;
      foreground = colorScheme.tertiary;
    } else {
      background = colorScheme.primary;
      foreground = colorScheme.onPrimary;
    }

    final icon = checkoutReady
        ? Icons.shopping_cart_checkout_rounded
        : lockedOut
        ? Icons.lock_outline_rounded
        : joined
        ? Icons.check_circle_rounded
        : Icons.shopping_bag_rounded;

    final formattedSubtotal = '\$${subtotal.toStringAsFixed(2)}';
    final label = checkoutReady
        ? l10n.coBuyDetailCheckoutLabel(formattedSubtotal)
        : lockedOut
        ? l10n.coBuyDetailFullLabel
        : joined
        ? l10n.coBuyDetailJoinedLabel
        : l10n.coBuyDetailJoinLabel(formattedSubtotal);

    const pillRadius = 999.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(pillRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(pillRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(pillRadius),
          onTap: lockedOut ? null : onTap,
          child: Container(
            decoration: joined && !checkoutReady
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(pillRadius),
                    border: Border.all(color: colorScheme.tertiary),
                  )
                : null,
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
