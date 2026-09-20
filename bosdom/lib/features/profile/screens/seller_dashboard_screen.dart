import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/hourglass_icon.dart';
import '../../../shared/widgets/order_status_badge.dart';
import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import '../models/seller_order.dart';
import '../models/shop_profile.dart';
import '../providers/profile_provider.dart';
import '../providers/shop_profile_provider.dart';
import '../widgets/seller_approval_gate.dart';

// Same header size/shape as SellerOrdersScreen so switching between a
// seller's dashboard and their orders list feels like the same app.
const _kHeaderContentHeight = 68.0;

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final shop = ref.watch(shopProfileProvider).value;
    final isVerifiedSeller =
        ref.watch(profileProvider).value?.isVerifiedSeller ?? false;
    final recentOrders =
        ref.watch(sellerOrdersProvider).value?.take(3).toList() ?? const [];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: RefreshIndicator(
                color: colorScheme.primary,
                onRefresh: () => _refresh(context, ref),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    20,
                    24,
                    16 + MediaQuery.of(context).padding.bottom,
                  ),
                  children: [
                    _StoreSummaryCard(
                      shop: shop,
                      isVerifiedSeller: isVerifiedSeller,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    if (!isVerifiedSeller) ...[
                      const SizedBox(height: 24),
                      _ApprovalPendingBanner(
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                    ],
                    const SizedBox(height: 24),
                    _SectionLabel(
                      l10n.sellerDashboardQuickActionsTitle,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 8),
                    _QuickActionsGrid(
                      actions: _sellerActions(l10n),
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    if (isVerifiedSeller) ...[
                      const SizedBox(height: 24),
                      _SectionLabel(
                        l10n.sellerDashboardPerformanceTitle,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                      const SizedBox(height: 12),
                      _PerformanceCard(
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                    ],
                    const SizedBox(height: 24),
                    _RecentOrdersHeader(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < recentOrders.length; i++) ...[
                      _RecentOrderTile(
                        order: recentOrders[i],
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
                      if (i != recentOrders.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    try {
      await Future.wait([
        ref.read(profileProvider.notifier).refresh(),
        ref.read(shopProfileProvider.notifier).refresh(),
        ref.read(sellerOrdersProvider.notifier).refresh(),
      ]);
    } catch (_) {
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileRefreshFailedSnackbar)),
      );
    }
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
              Row(
                children: [
                  InkWell(
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
                  const Spacer(),
                  InkWell(
                    onTap: () => context.pushNamed(
                      'chatList',
                      queryParameters: const {'seller': 'true'},
                    ),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                l10n.sellerDashboardScreenTitle,
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

class _StoreSummaryCard extends StatelessWidget {
  const _StoreSummaryCard({
    required this.shop,
    required this.isVerifiedSeller,
    required this.colorScheme,
    required this.textTheme,
  });

  final ShopProfile? shop;
  final bool isVerifiedSeller;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shopName = shop?.shopName ?? '';
    final logoUrl = ApiConfig.resolveAvatarUrl(shop?.logoUrl);

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
                child: ClipOval(
                  child: logoUrl != null
                      ? Image.network(
                          logoUrl,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                              ? child
                              : Icon(
                                  Icons.storefront_rounded,
                                  color: colorScheme.primary,
                                  size: 26,
                                ),
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.storefront_rounded,
                            color: colorScheme.primary,
                            size: 26,
                          ),
                        )
                      : Icon(
                          Icons.storefront_rounded,
                          color: colorScheme.primary,
                          size: 26,
                        ),
                ),
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
                            shopName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isVerifiedSeller) ...[
                          const SizedBox(width: 8),
                          const _VerifiedBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.sellerDashboardWelcomeMessage,
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
          if (isVerifiedSeller) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _SummaryStat(
                    label: l10n.sellerDashboardRevenueLabel,
                    value: '\$1,240',
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
                _SummaryDivider(colorScheme: colorScheme),
                Expanded(
                  child: _SummaryStat(
                    label: l10n.sellerDashboardPendingLabel,
                    value: l10n.sellerDashboardPendingOrdersLabel(8),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
                _SummaryDivider(colorScheme: colorScheme),
                Expanded(
                  child: _SummaryStat(
                    label: l10n.sellerDashboardProductsLabel,
                    value: l10n.sellerDashboardProductsCountLabel(24),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.verified_rounded, size: 18, color: AppColors.trustGreen);
  }
}

class _ApprovalPendingBanner extends ConsumerStatefulWidget {
  const _ApprovalPendingBanner({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  ConsumerState<_ApprovalPendingBanner> createState() =>
      _ApprovalPendingBannerState();
}

class _ApprovalPendingBannerState extends ConsumerState<_ApprovalPendingBanner>
    with SingleTickerProviderStateMixin {
  // A soft breathing glow behind the hourglass — a small visual cue that
  // review time is still ticking by, without leaning on extra color.
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final Animation<double> _pulse = CurvedAnimation(
    parent: _pulseController,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;
    final textTheme = widget.textTheme;
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(profileProvider).value;
    final rejected = profile?.verificationStatus == 'rejected';
    final statusColor = rejected ? colorScheme.error : colorScheme.primary;
    final statusDate = profile?.verificationUpdatedAt;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          rejected
              ? Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: statusColor,
                    size: 20,
                  ),
                )
              : AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) => Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(
                        alpha: 0.1 + _pulse.value * 0.08,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(
                            alpha: _pulse.value * 0.28,
                          ),
                          blurRadius: 4 + _pulse.value * 8,
                          spreadRadius: _pulse.value * 1.5,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                  child: HourglassIcon(size: 20, color: statusColor),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rejected
                      ? l10n.sellerApprovalRejectedTitle
                      : l10n.sellerApprovalPendingTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rejected
                      ? l10n.sellerApprovalRejectedMessage
                      : l10n.sellerApprovalPendingMessage,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                if (statusDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    rejected
                        ? l10n.sellerApprovalReviewedOnLabel(
                            DateFormat.yMMMd().format(statusDate.toLocal()),
                          )
                        : l10n.sellerApprovalSubmittedOnLabel(
                            DateFormat.yMMMd().format(statusDate.toLocal()),
                          ),
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (rejected) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: statusColor,
                    ),
                    onPressed: () => context.pushNamed('becomeSeller'),
                    child: Text(l10n.sellerApprovalResubmitAction),
                  ),
                ],
              ],
            ),
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
          label,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(
    this.label, {
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _QuickAction {
  const _QuickAction({required this.icon, required this.label, this.route});

  final IconData icon;
  final String label;
  final String? route;
}

List<_QuickAction> _sellerActions(AppLocalizations l10n) => [
  _QuickAction(
    icon: Icons.add_box_rounded,
    label: l10n.sellerDashboardAddListingAction,
    route: 'addListing',
  ),
  _QuickAction(
    icon: Icons.inventory_2_rounded,
    label: l10n.sellerDashboardMyInventoryAction,
    route: 'myInventory',
  ),
  _QuickAction(
    icon: Icons.receipt_long_rounded,
    label: l10n.sellerDashboardOrdersAction,
    route: 'sellerOrders',
  ),
  _QuickAction(
    icon: Icons.payments_rounded,
    label: l10n.sellerDashboardEarningsAction,
    route: 'sellerEarnings',
  ),
];

class _QuickActionsGrid extends ConsumerWidget {
  const _QuickActionsGrid({
    required this.actions,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<_QuickAction> actions;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  void _handleTap(BuildContext context, WidgetRef ref, _QuickAction action) {
    if (isSellerActionGated(ref, action.route)) {
      showSellerApprovalPendingDialog(context, ref);
      return;
    }
    if (action.route != null) {
      context.pushNamed(action.route!);
      return;
    }
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.commonComingSoon(action.label))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 128,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionCard(
          action: action,
          locked: isSellerActionGated(ref, action.route),
          colorScheme: colorScheme,
          textTheme: textTheme,
          onTap: () => _handleTap(context, ref, action),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.action,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
    this.locked = false,
  });

  final _QuickAction action;
  final bool locked;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = locked
        ? colorScheme.onSurfaceVariant
        : colorScheme.primary;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  locked ? Icons.lock_outline : action.icon,
                  size: 22,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: locked ? colorScheme.onSurfaceVariant : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
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
      child: Row(
        children: [
          Expanded(
            child: _PerformanceStat(
              icon: Icons.star_rounded,
              iconColor: AppColors.ratingGold,
              value: '4.8',
              label: l10n.sellerDashboardRatingLabel,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
          _SummaryDivider(colorScheme: colorScheme),
          Expanded(
            child: _PerformanceStat(
              icon: Icons.verified_rounded,
              iconColor: AppColors.trustGreen,
              value: '96%',
              label: l10n.sellerDashboardCompletionLabel,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
          _SummaryDivider(colorScheme: colorScheme),
          Expanded(
            child: _PerformanceStat(
              icon: Icons.schedule_rounded,
              iconColor: colorScheme.primary,
              value: '2d',
              label: l10n.sellerDashboardAvgDeliveryLabel,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceStat extends StatelessWidget {
  const _PerformanceStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RecentOrdersHeader extends StatelessWidget {
  const _RecentOrdersHeader({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SectionLabel(
          l10n.sellerDashboardRecentOrdersTitle,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => context.pushNamed('sellerOrders'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
    );
  }
}

class _RecentOrderTile extends ConsumerWidget {
  const _RecentOrderTile({
    required this.order,
    required this.colorScheme,
    required this.textTheme,
  });

  final Order order;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.pushNamed(
          'sellerOrderDetail',
          pathParameters: {'id': order.id},
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.ordersOrderNumberLabel(order.displayNumber),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.shippingName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatPrice(ref, order.totalAmount),
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  OrderStatusBadge(
                    label: sellerOrderStatusLabel(
                      order.status,
                      isSellerConfirmed: order.isSellerConfirmed,
                    ),
                    dense: true,
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
