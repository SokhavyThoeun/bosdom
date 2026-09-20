import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/api/admin_api_client.dart';
import '../../core/models/admin_models.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/async_loader.dart';
import '../../shared/widgets/charts.dart';
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

bool _counted(AdminOrder o) =>
    o.status != 'cancelled' && o.status != 'refunded';

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
    final counted = orders.where(_counted).toList();
    final revenue = counted.fold<double>(0, (s, o) => s + o.totalAmount);

    final ordersDaily = _daily(orders, (o) => o.createdAt);
    final revenueDaily = _daily(
      counted,
      (o) => o.createdAt,
      weight: (o) => o.totalAmount,
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
                label: 'Total Revenue',
                value: money.format(revenue),
                series: revenueDaily,
                color: AppColors.trustGreen,
                onTap: () => context.go('/orders'),
              ),
              _KpiCard(
                label: 'Orders',
                value: '${data.stats.orderCount}',
                series: ordersDaily,
                color: AppColors.brandCrimson,
                onTap: () => context.go('/orders'),
              ),
              _KpiCard(
                label: 'Buyers',
                value: '${data.stats.buyerCount}',
                series: usersDaily,
                color: AppColors.infoBlue,
                onTap: () => context.go('/users'),
              ),
              _KpiCard(
                label: 'Sellers',
                value: '${data.stats.sellerCount}',
                series: sellersDaily,
                color: AppColors.alertAmber,
                onTap: () => context.go('/sellers'),
              ),
              _KpiCard(
                label: 'Listings',
                value: '${data.stats.listingCount}',
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
                subtitle: 'Orders and sign-ups per day',
                height: 300,
                legend: const [
                  ('Orders', AppColors.brandCrimson),
                  ('New users', AppColors.infoBlue),
                ],
                child: AreaChart(
                  xLabels: labels,
                  series: [
                    ChartSeries('Orders', AppColors.brandCrimson, ordersDaily),
                    ChartSeries('New users', AppColors.infoBlue, usersDaily),
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
                    title: 'Top sellers',
                    subtitle: 'By order value',
                    child: _TopSellers(orders: counted),
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
        children: [for (final ch in children) SizedBox(width: w, child: ch)],
      );
    },
  );
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.series,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String value;
  final List<double> series;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = _trend(series);
    final up = (t ?? 0) >= 0;
    return Card(
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
                  Text(
                    value,
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
  Widget build(BuildContext context) => Card(
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
              width: 80,
              child: Text('TOTAL', style: head, textAlign: TextAlign.right),
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
                  width: 80,
                  child: Text(
                    currency.format(o.totalAmount),
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

class _TopSellers extends StatelessWidget {
  const _TopSellers({required this.orders});

  final List<AdminOrder> orders;

  @override
  Widget build(BuildContext context) {
    final totals = <String, double>{};
    for (final o in orders) {
      totals.update(
        o.sellerName,
        (v) => v + o.totalAmount,
        ifAbsent: () => o.totalAmount,
      );
    }
    final top = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (top.isEmpty) {
      return const Text(
        'No sales yet',
        style: TextStyle(color: AppColors.warmTaupe),
      );
    }
    final max = top.first.value;
    final currency = NumberFormat.compactCurrency(symbol: r'$');
    return Column(
      children: [
        for (final e in top.take(5))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      currency.format(e.value),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: max <= 0 ? 0 : e.value / max,
                    minHeight: 6,
                    backgroundColor: AppColors.blushSurface,
                    color: AppColors.brandCrimson,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
