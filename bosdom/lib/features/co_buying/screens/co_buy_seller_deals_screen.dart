import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../profile/models/shop_profile.dart';
import '../../profile/providers/shop_profile_provider.dart';
import '../models/co_buy_session.dart';
import '../providers/co_buy_provider.dart';
import '../widgets/co_buy_product_image.dart';

class CoBuySellerDealsScreen extends ConsumerWidget {
  const CoBuySellerDealsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final shop = ref.watch(shopProfileProvider).value;
    final deals = ref
        .watch(coBuyProvider)
        .where((s) => s.sellerName == shop?.shopName)
        .toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  20,
                  24,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  _DealsSummaryCard(
                    shop: shop,
                    deals: deals,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.pushNamed('coBuyCreate'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      l10n.coBuyDealsCreateButtonLabel,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.coBuyDealsListingsSectionTitle,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n.commonComingSoon(
                                l10n.sellerDashboardViewAllLabel,
                              ),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 4,
                          ),
                          child: Text(
                            l10n.sellerDashboardViewAllLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (deals.isEmpty)
                    _EmptyState(colorScheme: colorScheme, textTheme: textTheme)
                  else
                    for (var i = 0; i < deals.length; i++) ...[
                      _DealCard(
                        session: deals[i],
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        onEdit: () => context.pushNamed(
                          'coBuyCreate',
                          extra: deals[i].id,
                        ),
                        onDelete: () => _confirmDelete(context, ref, deals[i]),
                      ),
                      if (i != deals.length - 1) const SizedBox(height: 14),
                    ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CoBuySession session,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.coBuyDealsDeleteConfirmTitle),
        content: Text(
          l10n.coBuyDealsDeleteConfirmBody(session.productName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandCrimson,
            ),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    ref.read(coBuyProvider.notifier).delete(session.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.coBuyDealsDeletedSnackbar)));
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
          height: 96,
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
                l10n.profileMenuCoBuyDeals,
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

class _DealsSummaryCard extends StatelessWidget {
  const _DealsSummaryCard({
    required this.shop,
    required this.deals,
    required this.colorScheme,
    required this.textTheme,
  });

  final ShopProfile? shop;
  final List<CoBuySession> deals;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final logoUrl = ApiConfig.resolveAvatarUrl(shop?.logoUrl);
    final activeCount = deals
        .where((s) => s.dealStatus == CoBuyDealStatus.active)
        .length;
    final joinedCount = deals.fold<int>(0, (sum, s) => sum + s.retailersJoined);
    final revenue = deals.fold<double>(
      0,
      (sum, s) => sum + s.price * s.currentQty,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: logoUrl != null
                      ? NetworkImage(logoUrl)
                      : null,
                  child: logoUrl == null
                      ? Icon(
                          Icons.storefront_rounded,
                          color: colorScheme.primary,
                          size: 26,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              shop?.shopName.isNotEmpty == true
                                  ? shop!.shopName
                                  : l10n.coBuyDealsShopNamePlaceholder,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified_rounded,
                            size: 18,
                            color: AppColors.trustGreen,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.coBuyDealsWelcomeMessage,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: l10n.coBuyDealsActiveDealsLabel,
                  value: '$activeCount',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
              _SummaryDivider(colorScheme: colorScheme),
              Expanded(
                child: _SummaryStat(
                  label: l10n.coBuyDealsJoinedLabel,
                  value: '$joinedCount',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
              _SummaryDivider(colorScheme: colorScheme),
              Expanded(
                child: _SummaryStat(
                  label: l10n.coBuyDealsRevenueLabel,
                  value: '\$${revenue.toStringAsFixed(0)}',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final String value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: colorScheme.outline,
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({
    required this.session,
    required this.colorScheme,
    required this.textTheme,
    required this.onEdit,
    required this.onDelete,
  });

  final CoBuySession session;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color _statusColor() => switch (session.dealStatus) {
    CoBuyDealStatus.active => AppColors.trustGreen,
    CoBuyDealStatus.completed => AppColors.infoBlue,
    CoBuyDealStatus.expired => AppColors.brandCrimson,
  };

  String _statusLabel(AppLocalizations l10n) => switch (session.dealStatus) {
    CoBuyDealStatus.active => l10n.coBuyDealsStatusActive,
    CoBuyDealStatus.completed => l10n.coBuyDealsStatusCompleted,
    CoBuyDealStatus.expired => l10n.coBuyDealsStatusExpired,
  };

  String _clockLabel(AppLocalizations l10n) => switch (session.dealStatus) {
    CoBuyDealStatus.active => session.timeLeft,
    CoBuyDealStatus.completed => l10n.commonDone,
    CoBuyDealStatus.expired => l10n.coBuyDealsStatusEndedLabel,
  };

  String _rightLabel(AppLocalizations l10n) => switch (session.dealStatus) {
    CoBuyDealStatus.active => l10n.coBuyDealsEndsSoonLabel,
    CoBuyDealStatus.completed => l10n.coBuyDealsStatusCompleted,
    CoBuyDealStatus.expired => l10n.coBuyDealsStatusExpired,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progressPct = (session.progress.clamp(0, 1) * 100).round();
    final statusColor = _statusColor();
    final unitSuffix = session.perUnitLabel.startsWith('per ')
        ? session.perUnitLabel.substring(4)
        : session.unitLabel;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: CoBuyProductImage(session: session, iconSize: 22),
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
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.coBuyDealsMinTargetLabel(
                        session.targetQty,
                        session.unitLabel,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: _statusLabel(l10n),
                color: statusColor,
                textTheme: textTheme,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.coBuyDealsProgressLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$progressPct%',
                style: textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: session.progress.clamp(0, 1),
              minHeight: 8,
              backgroundColor: colorScheme.primaryContainer,
              valueColor: AlwaysStoppedAnimation(statusColor),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.coBuyDealsRetailersLabel(session.retailersJoined),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (session.autoRenew) ...[
                const SizedBox(width: 10),
                Icon(Icons.autorenew_rounded, size: 14, color: AppColors.infoBlue),
                const SizedBox(width: 3),
                Text(
                  l10n.coBuyDealsAutoRenewBadge,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.infoBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(width: 14),
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _clockLabel(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                _rightLabel(l10n),
                style: textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.coBuyDealsOriginalLabel.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${session.originalPrice.toStringAsFixed(2)} / $unitSuffix',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.coBuyDealsCoBuyPriceLabel.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${session.price.toStringAsFixed(2)} / $unitSuffix',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandCrimson,
                    side: const BorderSide(color: AppColors.brandCrimson),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: Text(
                    l10n.commonEdit,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandCrimson,
                    side: const BorderSide(color: AppColors.brandCrimson),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(
                    l10n.commonDelete,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.textTheme,
  });

  final String label;
  final Color color;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10.5,
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
        padding: const EdgeInsets.only(top: 24, bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.coBuyDealsEmptyMessage,
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
