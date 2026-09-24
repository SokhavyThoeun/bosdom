import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../marketplace/widgets/empty_products_notice.dart';
import '../../wishlist/providers/wishlist_provider.dart';
import '../models/co_buy_session.dart';
import '../providers/co_buy_provider.dart';
import '../services/co_buy_pool_service.dart';
import '../widgets/co_buy_product_image.dart';

class CoBuyingScreen extends ConsumerWidget {
  const CoBuyingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final sessionsAsync = ref.watch(coBuyProvider);
    final wishlistIds = ref.watch(wishlistProvider).value ?? const {};

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F7),
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: sessionsAsync.when(
                data: (sessions) => ListView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    20,
                    24,
                    8 + MediaQuery.of(context).padding.bottom,
                  ),
                  children: [
                    _InfoBanner(colorScheme: colorScheme, textTheme: textTheme),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      count: sessions.length,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 14),
                    if (sessions.isEmpty)
                      EmptyProductsNotice(
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        message: l10n.coBuyingEmptyMessage,
                      )
                    else
                      for (var i = 0; i < sessions.length; i++) ...[
                        _CoBuyCard(
                          session: sessions[i],
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                          isWishlisted: wishlistIds.contains(
                            coBuyWishlistId(sessions[i].id),
                          ),
                          onShare: (shareContext) =>
                              _shareSession(shareContext, sessions[i]),
                          onToggleJoin: () =>
                              _handleToggleJoin(context, ref, sessions[i]),
                          onToggleWishlist: () => ref
                              .read(wishlistProvider.notifier)
                              .toggle(coBuyWishlistId(sessions[i].id)),
                          onOpenDetail: () => context.pushNamed(
                            'coBuyDetail',
                            pathParameters: {'id': sessions[i].id},
                          ),
                        ),
                        if (i != sessions.length - 1)
                          const SizedBox(height: 14),
                      ],
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: EmptyProductsNotice(
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    message: l10n.coBuyingLoadError,
                    onRetry: () => ref.invalidate(coBuyProvider),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggleJoin(
    BuildContext context,
    WidgetRef ref,
    CoBuySession session,
  ) async {
    try {
      if (session.joined) {
        await ref.read(coBuyProvider.notifier).leave(session.id);
      } else {
        await ref
            .read(coBuyProvider.notifier)
            .join(session.id, quantity: session.minOrderQty);
      }
    } on CoBuyJoinException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _shareSession(BuildContext context, CoBuySession session) async {
    final l10n = AppLocalizations.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null
        ? (box.localToGlobal(Offset.zero) & box.size)
        : null;

    await SharePlus.instance.share(
      ShareParams(
        text: l10n.coBuyingShareText(
          session.productName,
          '\$${session.price.toStringAsFixed(2)}',
          '${session.savingsPct}',
          'https://bosdom.app/co-buying/${session.id}',
        ),
        subject: l10n.coBuyingShareSubject(session.productName),
        sharePositionOrigin: origin,
      ),
    );
  }
}

// Matches the combined height of the logo/notification row + search bar
// used by the homepage and wishlist headers, so this header is the same
// overall size even though it shows a back row + centered title.
const _kHeaderContentHeight = 68.0;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => context.pop(),
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
                l10n.coBuyingScreenTitle,
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

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lightbulb_outline_rounded,
              size: 17,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.coBuyingInfoBanner,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.count,
    required this.colorScheme,
    required this.textTheme,
  });

  final int count;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Flexible(
          child: Text(
            l10n.coBuyingSectionTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _CoBuyCard extends StatelessWidget {
  const _CoBuyCard({
    required this.session,
    required this.colorScheme,
    required this.textTheme,
    required this.isWishlisted,
    required this.onShare,
    required this.onToggleJoin,
    required this.onToggleWishlist,
    required this.onOpenDetail,
  });

  final CoBuySession session;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isWishlisted;
  final void Function(BuildContext shareContext) onShare;
  final VoidCallback onToggleJoin;
  final VoidCallback onToggleWishlist;
  final VoidCallback onOpenDetail;

  IconData get _momentumIcon {
    if (session.isFull) return Icons.check_circle_rounded;
    if (session.progress >= 0.8) return Icons.local_fire_department_rounded;
    if (session.progress >= 0.5) return Icons.trending_up_rounded;
    return Icons.storefront_rounded;
  }

  String _momentumLine(AppLocalizations l10n) {
    if (session.isFull) return l10n.coBuyingMomentumReady;
    if (session.progress >= 0.8) return l10n.coBuyingMomentumAlmost;
    if (session.progress >= 0.5) return l10n.coBuyingMomentumFilling;
    return l10n.coBuyingMomentumNew;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progressPct = (session.progress * 100).round();
    final savingsAmount = session.originalPrice - session.price;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpenDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero banner: makes the deal read as an event, not a line item.
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withValues(alpha: 0.82),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: CoBuyProductImage(session: session),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.sellerName,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onToggleWishlist,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: colorScheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  Builder(
                    builder: (shareContext) => InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => onShare(shareContext),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.ios_share_rounded,
                          size: 18,
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        _momentumIcon,
                        size: 16,
                        color: colorScheme.tertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _momentumLine(l10n),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _SavingsBadge(
                        pct: session.savingsPct,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.coBuyingPooledProgress(
                            session.currentQty,
                            session.targetQty,
                            session.unitLabel,
                          ),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '$progressPct%',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: session.progress,
                      minHeight: 10,
                      backgroundColor: colorScheme.primaryContainer,
                      valueColor: AlwaysStoppedAnimation(colorScheme.tertiary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.coBuyingRemainingToUnlock(
                      session.remainingQty,
                      session.unitLabel,
                    ),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: colorScheme.error,
                        ),
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
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.coBuyingGroupPriceLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 8,
                    children: [
                      Text(
                        '\$${session.price.toStringAsFixed(2)}',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${session.originalPrice.toStringAsFixed(2)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    l10n.coBuyingYouSave(
                      '\$${savingsAmount.toStringAsFixed(2)}',
                    ),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (session.isFull && session.joined)
                    _CheckoutReadyPill(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: onOpenDetail,
                    )
                  else if (session.isFull)
                    _FullLockedPill(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    )
                  else if (session.joined)
                    _JoinedPill(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: onToggleJoin,
                    )
                  else
                    _JoinButton(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: onToggleJoin,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavingsBadge extends StatelessWidget {
  const _SavingsBadge({
    required this.pct,
    required this.colorScheme,
    required this.textTheme,
  });

  final int pct;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$pct% OFF',
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.tertiary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _JoinedPill extends StatelessWidget {
  const _JoinedPill({
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
      color: colorScheme.tertiary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.tertiary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: colorScheme.tertiary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  l10n.coBuyingJoinedPillLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
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

class _CheckoutReadyPill extends StatelessWidget {
  const _CheckoutReadyPill({
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
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_checkout_rounded,
                size: 18,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.coBuyingCheckoutReadyLabel,
                style: textTheme.labelMedium?.copyWith(
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

class _FullLockedPill extends StatelessWidget {
  const _FullLockedPill({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.coBuyingFullLabel,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  const _JoinButton({
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
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_rounded,
                size: 18,
                color: colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.coBuyingJoinButtonLabel,
                style: textTheme.labelMedium?.copyWith(
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
