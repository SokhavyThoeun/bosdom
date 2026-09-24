import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/api/admin_api_client.dart';
import '../../core/models/admin_models.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/async_loader.dart';
import '../../shared/widgets/charts.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/widgets/status_pill.dart';

/// Everything the dashboard shows, fetched once. Analytics are derived
/// client-side from the existing admin endpoints (no extra backend route).
class _DashboardData {
  const _DashboardData({
    required this.stats,
    required this.orders,
    required this.users,
    required this.sellers,
    required this.listings,
  });

  final AdminStats stats;
  final List<AdminOrder> orders;
  final List<AdminUser> users;
  final List<AdminSeller> sellers;
  final List<AdminListing> listings;
}

Future<_DashboardData> _load() async {
  final r = await Future.wait([
    AdminApiClient.fetchStats(),
    AdminApiClient.fetchOrders(),
    AdminApiClient.fetchUsers(),
    AdminApiClient.fetchSellers(),
    AdminApiClient.fetchListings(),
  ]);
  return _DashboardData(
    stats: r[0] as AdminStats,
    orders: r[1] as List<AdminOrder>,
    users: r[2] as List<AdminUser>,
    sellers: r[3] as List<AdminSeller>,
    listings: r[4] as List<AdminListing>,
  );
}

const _days = 14;

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

/// Per-day counts/sums for the last [_days] days, oldest first.
List<double> _daily<T>(
  Iterable<T> items,
  DateTime Function(T) at, {
  double Function(T)? weight,
}) {
  final today = _day(DateTime.now());
  final out = List<double>.filled(_days, 0);
  for (final item in items) {
    final diff = today.difference(_day(at(item).toLocal())).inDays;
    if (diff >= 0 && diff < _days) {
      out[_days - 1 - diff] += weight == null ? 1 : weight(item);
    }
  }
  return out;
}

/// % change of the last 7 days vs the 7 before; null when there's no base.
double? _trend(List<double> v) {
  final prev = v.sublist(0, 7).fold<double>(0, (a, b) => a + b);
  final cur = v.sublist(7).fold<double>(0, (a, b) => a + b);
  if (prev == 0) return cur == 0 ? null : 100;
  return (cur - prev) / prev * 100;
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: AsyncLoader<_DashboardData>(
            loader: _load,
            builder: (context, data, reload) =>
                _DashboardBody(data: data, onRefresh: reload),
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data, required this.onRefresh});

  final _DashboardData data;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.compactCurrency(symbol: r'$');
    final orders = data.orders;
    final commission = orders.fold<double>(
      0,
      (s, o) => s + (o.platformFee ?? 0),
    );

    final ordersDaily = _daily(orders, (o) => o.createdAt);
    final commissionDaily = _daily(
      orders.where((o) => o.platformFee != null),
      (o) => o.createdAt,
      weight: (o) => o.platformFee ?? 0,
    );
    final usersDaily = _daily(data.users, (u) => u.createdAt);
    final sellersDaily = _daily(data.sellers, (s) => s.createdAt);
    final listingsDaily = _daily(data.listings, (l) => l.createdAt);

    final labels = [
      for (var i = _days - 1; i >= 0; i--)
        DateFormat.MMMd().format(DateTime.now().subtract(Duration(days: i))),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeaderInline(
            title: 'Dashboard',
            subtitle: 'How BosDom is performing over the last $_days days',
            actions: [
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _Grid(
            minTile: 230,
            children: [
              _KpiCard(
                label: 'Commission Earned',
                value: commission,
                format: money.format,
                series: commissionDaily,
                color: AppColors.trustGreen,
                onTap: () => context.go('/orders'),
              ),
              _KpiCard(
                label: 'Orders',
                value: data.stats.orderCount.toDouble(),
                series: ordersDaily,
                color: AppColors.brandCrimson,
                onTap: () => context.go('/orders'),
              ),
              _KpiCard(
                label: 'Buyers',
                value: data.stats.buyerCount.toDouble(),
                series: usersDaily,
                color: AppColors.infoBlue,
                onTap: () => context.go('/users'),
              ),
              _KpiCard(
                label: 'Sellers',
                value: data.stats.sellerCount.toDouble(),
                series: sellersDaily,
                color: AppColors.alertAmber,
                onTap: () => context.go('/sellers'),
              ),
              _KpiCard(
                label: 'Listings',
                value: data.stats.listingCount.toDouble(),
                series: listingsDaily,
                color: AppColors.ratingGold,
                onTap: () => context.go('/listings'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 900;
              final trend = _Panel(
                title: 'Activity',
                subtitle: 'Orders, sign-ups and new listings per day',
                height: 300,
                legend: const [
                  ('Orders', AppColors.brandCrimson),
                  ('New buyers', AppColors.infoBlue),
                  ('New sellers', AppColors.alertAmber),
                  ('New listings', AppColors.ratingGold),
                ],
                child: AreaChart(
                  xLabels: labels,
                  series: [
                    ChartSeries('Orders', AppColors.brandCrimson, ordersDaily),
                    ChartSeries('New buyers', AppColors.infoBlue, usersDaily),
                    ChartSeries(
                      'New sellers',
                      AppColors.alertAmber,
                      sellersDaily,
                    ),
                    ChartSeries(
                      'New listings',
                      AppColors.ratingGold,
                      listingsDaily,
                    ),
                  ],
                ),
              );
              final status = _Panel(
                title: 'Orders by status',
                subtitle: 'All time',
                height: 300,
                child: _StatusDonut(orders: orders),
              );
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: trend),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: status),
                      ],
                    )
                  : Column(
                      children: [trend, const SizedBox(height: 20), status],
                    );
            },
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 900;
              final recent = _Panel(
                title: 'Recent orders',
                action: TextButton(
                  onPressed: () => context.go('/orders'),
                  child: const Text('View all'),
                ),
                child: _RecentOrders(orders: orders.take(6).toList()),
              );
              final side = Column(
                children: [
                  _Panel(
                    title: 'Needs attention',
                    child: _Attention(stats: data.stats),
                  ),
                  const SizedBox(height: 20),
                  _Panel(
                    title: 'Commission',
                    subtitle: 'Platform fee: 4% (3% for reduced-fee sellers)',
                    child: _CommissionSummary(orders: orders),
                  ),
                  const SizedBox(height: 20),
                  _Panel(
                    title: 'New this week',
                    subtitle: 'Joined or uploaded in the last 7 days',
                    child: _NewActivity(
                      buyers: usersDaily
                          .sublist(7)
                          .fold<double>(0, (a, b) => a + b)
                          .toInt(),
                      sellers: sellersDaily
                          .sublist(7)
                          .fold<double>(0, (a, b) => a + b)
                          .toInt(),
                      listings: listingsDaily
                          .sublist(7)
                          .fold<double>(0, (a, b) => a + b)
                          .toInt(),
                    ),
                  ),
                ],
              );
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: recent),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: side),
                      ],
                    )
                  : Column(
                      children: [recent, const SizedBox(height: 20), side],
                    );
            },
          ),
        ],
      ),
    );
  }
}

/// Header without the shell's outer padding (the body already pads).
class AdminPageHeaderInline extends StatelessWidget {
  const AdminPageHeaderInline({
    required this.title,
    required this.subtitle,
    this.actions,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.warmTaupe, fontSize: 14),
            ),
          ],
        ),
      ),
      ...?actions,
    ],
  );
}

/// Responsive grid: as many [minTile]-wide columns as fit, tiles stretch.
class _Grid extends StatelessWidget {
  const _Grid({required this.children, required this.minTile});

  final List<Widget> children;
  final double minTile;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      const gap = 16.0;
      final cols = ((c.maxWidth + gap) / (minTile + gap)).floor().clamp(1, 6);
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (var i = 0; i < children.length; i++)
            SizedBox(
              width: w,
              child: Reveal(
                delay: Duration(milliseconds: 70 * i),
                child: children[i],
              ),
            ),
        ],
      );
    },
  );
}

String _whole(double v) => v.round().toString();

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.series,
    required this.color,
    required this.onTap,
    this.format = _whole,
  });

  final String label;
  final double value;
  final String Function(double) format;
  final List<double> series;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = _trend(series);
    final up = (t ?? 0) >= 0;
    return HoverLift(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.warmTaupe,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CountUp(
                      value: value,
                      format: format,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (t != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              up ? Icons.trending_up : Icons.trending_down,
                              size: 16,
                              color: up
                                  ? AppColors.trustGreen
                                  : const Color(0xFFB3261E),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${t.abs().round()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: up
                                    ? AppColors.trustGreen
                                    : const Color(0xFFB3261E),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 38,
                  child: Sparkline(values: series, color: color),
                ),
                const SizedBox(height: 4),
                const Text(
                  'vs previous 7 days',
                  style: TextStyle(color: AppColors.warmTaupe, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.height,
    this.legend,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget child;
  final double? height;
  final List<(String, Color)>? legend;

  @override
  Widget build(BuildContext context) => Reveal(
    delay: const Duration(milliseconds: 300),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: AppColors.warmTaupe,
                            fontSize: 12.5,
                          ),
                        ),
                    ],
                  ),
                ),
                ?action,
              ],
            ),
            if (legend != null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                children: [
                  for (final (label, color) in legend!)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.warmTaupe,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (height != null)
              SizedBox(height: height! - 90, child: child)
            else
              child,
          ],
        ),
      ),
    ),
  );
}

class _StatusDonut extends StatelessWidget {
  const _StatusDonut({required this.orders});

  final List<AdminOrder> orders;

  static const _defs = [
    ('released', 'Released', AppColors.trustGreen),
    ('held', 'Held (escrow)', AppColors.infoBlue),
    ('pending', 'Pending', AppColors.ratingGold),
    ('disputed', 'Disputed', Color(0xFFB3261E)),
    ('refunded', 'Refunded', AppColors.roseMist),
    ('cancelled', 'Cancelled', AppColors.warmTaupe),
  ];

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'No orders yet',
          style: TextStyle(color: AppColors.warmTaupe),
        ),
      );
    }
    int count(String key) => orders
        .where(
          (o) => key == 'pending'
              ? !_defs.any((d) => d.$1 == o.status && d.$1 != 'pending')
              : o.status == key,
        )
        .length;
    final slices = [
      for (final d in _defs) DonutSlice(d.$2, d.$3, count(d.$1).toDouble()),
    ];
    return Row(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: DonutChart(
            slices: slices,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${orders.length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'orders',
                  style: TextStyle(color: AppColors.warmTaupe, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final s in slices)
                if (s.value > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: s.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.label,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          '${s.value.toInt()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
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

class _RecentOrders extends StatelessWidget {
  const _RecentOrders({required this.orders});

  final List<AdminOrder> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No orders yet',
            style: TextStyle(color: AppColors.warmTaupe),
          ),
        ),
      );
    }
    final currency = NumberFormat.currency(symbol: r'$');
    const head = TextStyle(
      color: AppColors.warmTaupe,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    );
    return Column(
      children: [
        const Row(
          children: [
            Expanded(flex: 4, child: Text('PRODUCT', style: head)),
            Expanded(flex: 3, child: Text('BUYER', style: head)),
            Expanded(flex: 3, child: Text('STATUS', style: head)),
            SizedBox(
              width: 100,
              child: Text(
                'COMMISSION',
                style: head,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final o in orders) ...[
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    o.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    o.buyerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.warmTaupe),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: StatusPill.orderStatus(o.status),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    o.platformFee == null
                        ? '—'
                        : currency.format(o.platformFee),
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Attention extends StatelessWidget {
  const _Attention({required this.stats});

  final AdminStats stats;

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, Color color, String label, int n, String path) =>
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(path),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '$n',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: n > 0 ? color : AppColors.warmTaupe,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.warmTaupe,
                ),
              ],
            ),
          ),
        );
    return Column(
      children: [
        row(
          Icons.gavel,
          const Color(0xFFB3261E),
          'Open disputes',
          stats.pendingDisputes,
          '/orders',
        ),
        row(
          Icons.fact_check_outlined,
          AppColors.alertAmber,
          'Pending KYC reviews',
          stats.pendingKyc,
          '/sellers',
        ),
      ],
    );
  }
}

class _NewActivity extends StatelessWidget {
  const _NewActivity({
    required this.buyers,
    required this.sellers,
    required this.listings,
  });

  final int buyers;
  final int sellers;
  final int listings;

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, Color color, String label, int n) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '+$n',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: n > 0 ? color : AppColors.warmTaupe,
            ),
          ),
        ],
      ),
    );
    return Column(
      children: [
        row(Icons.person_add_alt, AppColors.infoBlue, 'New buyers', buyers),
        row(
          Icons.storefront_outlined,
          AppColors.alertAmber,
          'New sellers',
          sellers,
        ),
        row(
          Icons.add_box_outlined,
          AppColors.ratingGold,
          'New listings',
          listings,
        ),
      ],
    );
  }
}

/// Earned = fees already taken on released orders. Pending = the 4% we
/// expect from orders still in escrow, dispute or awaiting payment.
class _CommissionSummary extends StatelessWidget {
  const _CommissionSummary({required this.orders});

  final List<AdminOrder> orders;

  static const _pendingStatuses = {'held', 'pending', 'disputed'};

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: r'$');
    final earnedOrders = orders.where((o) => o.platformFee != null).toList();
    final earned = earnedOrders.fold<double>(0, (a, o) => a + o.platformFee!);
    final pending = orders
        .where(
          (o) => o.platformFee == null && _pendingStatuses.contains(o.status),
        )
        .fold<double>(0, (a, o) => a + o.totalAmount * 0.04);
    final avg = earnedOrders.isEmpty ? 0.0 : earned / earnedOrders.length;
    final total = earned + pending;

    Widget row(Color color, String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: total <= 0 ? 0 : earned / total),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: AppColors.blushSurface,
              color: AppColors.trustGreen,
            ),
          ),
        ),
        const SizedBox(height: 10),
        row(AppColors.trustGreen, 'Earned (released)', money.format(earned)),
        row(AppColors.infoBlue, 'Pending (in escrow)', money.format(pending)),
        row(AppColors.warmTaupe, 'Avg per released order', money.format(avg)),
      ],
    );
  }
}
