import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/api/admin_api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/models/admin_models.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/admin_shell.dart';
import '../../shared/widgets/async_loader.dart';
import '../../shared/widgets/confirm_action.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/message_user_button.dart';
import '../../shared/widgets/photo_viewer.dart';
import '../../shared/widgets/status_pill.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminPageHeader(
          title: 'Orders & Disputes',
          subtitle:
              'Escrow status across the marketplace, and dispute resolution',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 4, 28, 0),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 20),
            labelColor: AppColors.brandCrimson,
            unselectedLabelColor: AppColors.warmTaupe,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            indicatorColor: AppColors.brandCrimson,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            dividerColor: AppColors.brandCrimson.withValues(alpha: 0.15),
            overlayColor: WidgetStatePropertyAll(
              AppColors.brandCrimson.withValues(alpha: 0.06),
            ),
            tabs: const [
              Tab(height: 48, text: 'All Orders'),
              Tab(height: 48, text: 'Withdrawal Requests'),
              Tab(height: 48, text: 'Disputes'),
              Tab(height: 48, text: 'Seller Reports'),
              Tab(height: 48, text: 'Co-Buy Refunds'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _OrdersTab(),
              _PayoutsTab(),
              _DisputesTab(),
              _SellerReportsTab(),
              _CoBuyLeavesTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: r'$');
    return AsyncLoader<List<AdminOrder>>(
      loader: AdminApiClient.fetchOrders,
      builder: (context, orders, reload) {
        if (orders.isEmpty) {
          return const EmptyState(message: 'No orders yet.');
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: const [
                        DataColumn(
                          label: Text('PRODUCT'),
                          columnWidth: FlexColumnWidth(),
                        ),
                        DataColumn(label: Text('BUYER')),
                        DataColumn(label: Text('SELLER')),
                        DataColumn(label: Text('TOTAL')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('STAGE')),
                        DataColumn(label: Text('CREATED')),
                      ],
                      rows: [
                        for (final order in orders)
                          DataRow(
                            cells: [
                              DataCell(
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 220,
                                  ),
                                  child: Text(
                                    order.productName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(order.buyerName)),
                              DataCell(Text(order.sellerName)),
                              DataCell(
                                Text(currency.format(order.totalAmount)),
                              ),
                              DataCell(StatusPill.orderStatus(order.status)),
                              DataCell(Text(order.stageLabel)),
                              DataCell(
                                Text(
                                  DateFormat.yMMMd().format(order.createdAt),
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
    );
  }
}

class _PayoutsTab extends StatelessWidget {
  const _PayoutsTab();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: r'$');
    return AsyncLoader<List<AdminPayoutRequest>>(
      loader: AdminApiClient.fetchPayoutRequests,
      refreshInterval: const Duration(seconds: 10),
      builder: (context, requests, reload) {
        if (requests.isEmpty) {
          return const EmptyState(
            message: 'No withdrawal requests from sellers yet.',
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: const [
                        DataColumn(
                          label: Text('PRODUCT'),
                          columnWidth: FlexColumnWidth(),
                        ),
                        DataColumn(label: Text('SELLER')),
                        DataColumn(label: Text('BUYER')),
                        DataColumn(label: Text('AMOUNT')),
                        DataColumn(label: Text('PAYOUT')),
                        DataColumn(label: Text('REQUESTED')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: [
                        for (final request in requests)
                          DataRow(
                            cells: [
                              DataCell(
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 220,
                                  ),
                                  child: Text(
                                    request.productName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(request.sellerName)),
                              DataCell(Text(request.buyerName)),
                              DataCell(
                                Text(currency.format(request.totalAmount)),
                              ),
                              DataCell(
                                Text(
                                  currency.format(request.payoutAmount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  DateFormat.yMMMd().format(
                                    request.requestedAt,
                                  ),
                                ),
                              ),
                              DataCell(
                                request.isApproved
                                    ? const StatusPill(
                                        label: 'Approved',
                                        tone: PillTone.success,
                                      )
                                    : const StatusPill(
                                        label: 'Awaiting approval',
                                        tone: PillTone.warning,
                                      ),
                              ),
                              DataCell(
                                request.isApproved
                                    ? Text(
                                        'Sent to bank',
                                        style: TextStyle(
                                          color: AppColors.warmTaupe,
                                        ),
                                      )
                                    : TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.trustGreen,
                                        ),
                                        onPressed: !request.isApproved
                                            ? () => confirmAndRun(
                                                context,
                                                title: 'Approve withdrawal?',
                                                message:
                                                    'Send ${currency.format(request.payoutAmount)} (${currency.format(request.totalAmount)} minus the platform fee) to ${request.sellerName}\'s bank: ${request.bankName ?? '-'} · ${request.accountHolder ?? '-'} · ${request.accountNumber ?? '-'}. It reaches them in 1 to 3 hours.',
                                                confirmLabel: 'Approve',
                                                action: () =>
                                                    AdminApiClient.releasePayout(
                                                      request.orderId,
                                                    ),
                                                onSuccess: reload,
                                              )
                                            : null,
                                        child: const Text('Approve'),
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
    );
  }
}

class _DisputesTab extends StatelessWidget {
  const _DisputesTab();

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<List<AdminDispute>>(
      loader: AdminApiClient.fetchDisputes,
      refreshInterval: const Duration(seconds: 15),
      builder: (context, disputes, reload) {
        if (disputes.isEmpty) {
          return const EmptyState(message: 'No reported problems.');
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
          itemCount: disputes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (context, i) =>
              _CaseCard(dispute: disputes[i], onChanged: reload),
        );
      },
    );
  }
}

/// One reported problem, laid out as the admin's process: report → case
/// opened → seller and courier reply → admin decides who is at fault.
class _CaseCard extends StatelessWidget {
  const _CaseCard({required this.dispute, required this.onChanged});

  final AdminDispute dispute;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final d = dispute;
    final currency = NumberFormat.currency(symbol: r'$');
    final date = DateFormat.yMMMd().add_jm();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    d.orderProductName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                StatusPill.disputeStatus(d.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${currency.format(d.orderTotalAmount)} · Buyer ${d.buyerName} · Seller ${d.sellerName} · reported ${date.format(d.createdAt.toLocal())}',
              style: TextStyle(color: AppColors.warmTaupe),
            ),
            const SizedBox(height: 16),
            _Step(
              title: 'Buyer reported: ${d.reason.replaceAll('_', ' ')}',
              detail: [
                if (d.note.isNotEmpty) d.note,
                if (d.frozenSecondsLeft != null)
                  'Review timer frozen with ${_left(d.frozenSecondsLeft!)} left.',
              ].join('\n'),
              done: true,
            ),
            _Step(
              title: 'Admin opens case',
              detail: d.caseOpenedAt == null
                  ? null
                  : date.format(d.caseOpenedAt!.toLocal()),
              done: d.caseOpenedAt != null,
            ),
            _Step(
              title: 'Seller reply',
              detail:
                  d.sellerResponse ??
                  (d.isCaseOpen ? 'Waiting for the seller…' : null),
              done: d.sellerResponse != null,
            ),
            _Step(
              title: 'Courier reply',
              detail:
                  d.courierResponse ??
                  (d.isCaseOpen
                      ? 'Contact the courier and record their reply.'
                      : null),
              done: d.courierResponse != null,
            ),
            _Step(
              title: d.isResolved
                  ? 'Decision: ${d.resolution == 'refund' ? 'refund buyer' : 'release to seller'} · fault: ${d.fault ?? 'none'}'
                  : 'Admin decides who is at fault',
              done: d.isResolved,
              last: true,
            ),
            if (_hasProof) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  if (d.shippingPhotoUrl != null)
                    _ProofImage(
                      label: 'Parcel photo',
                      url: d.shippingPhotoUrl!,
                    ),
                  if (d.deliveryProofUrl != null)
                    _ProofImage(
                      label: 'Proof of delivery',
                      url: d.deliveryProofUrl!,
                    ),
                ],
              ),
              if (d.courier != null || d.trackingNumber != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Courier: ${d.courier ?? '-'} · Tracking: ${d.trackingNumber ?? '-'}',
                    style: TextStyle(color: AppColors.warmTaupe),
                  ),
                ),
            ],
            if (!d.isResolved) ...[
              const SizedBox(height: 16),
              Wrap(spacing: 8, runSpacing: 8, children: _actions(context)),
            ],
          ],
        ),
      ),
    );
  }

  bool get _hasProof =>
      dispute.shippingPhotoUrl != null || dispute.deliveryProofUrl != null;

  static String _left(int seconds) {
    final h = seconds ~/ 3600;
    return h >= 24
        ? '${h ~/ 24}d ${h % 24}h'
        : '${h}h ${(seconds ~/ 60) % 60}m';
  }

  List<Widget> _actions(BuildContext context) {
    final d = dispute;
    final currency = NumberFormat.currency(symbol: r'$');
    if (!d.isCaseOpen) {
      return [
        FilledButton(
          onPressed: () => confirmAndRun(
            context,
            title: 'Open a case?',
            message:
                'The seller will be asked to reply, and you can record the courier\'s reply before deciding.',
            confirmLabel: 'Open case',
            action: () => AdminApiClient.openDisputeCase(d.id),
            onSuccess: onChanged,
          ),
          child: const Text('Open case'),
        ),
      ];
    }
    return [
      OutlinedButton(
        onPressed: () async {
          final text = await _askText(context, 'Courier reply');
          if (text == null || !context.mounted) return;
          await confirmAndRun(
            context,
            title: 'Save courier reply?',
            message: text,
            confirmLabel: 'Save',
            action: () => AdminApiClient.recordCourierReply(d.id, text),
            onSuccess: onChanged,
          );
        },
        child: Text(
          d.courierResponse == null
              ? 'Record courier reply'
              : 'Edit courier reply',
        ),
      ),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.warmTaupe),
        onPressed: () async {
          final fault = await _askFault(context);
          if (fault == null || !context.mounted) return;
          await confirmAndRun(
            context,
            title: 'Refund the buyer?',
            message:
                '${currency.format(d.orderTotalAmount)} goes back to ${d.buyerName}. Fault: $fault.',
            confirmLabel: 'Refund buyer',
            destructive: true,
            action: () =>
                AdminApiClient.resolveDispute(d.id, 'refund', fault: fault),
            onSuccess: onChanged,
          );
        },
        child: const Text('Refund buyer'),
      ),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.trustGreen),
        onPressed: () async {
          final fault = await _askFault(context, initial: 'buyer');
          if (fault == null || !context.mounted) return;
          await confirmAndRun(
            context,
            title: 'Release to seller?',
            message:
                '${d.sellerName} receives ${currency.format(d.sellerPayout)} (${currency.format(d.platformFee)} platform fee taken). Fault: $fault.',
            confirmLabel: 'Release',
            action: () =>
                AdminApiClient.resolveDispute(d.id, 'release', fault: fault),
            onSuccess: onChanged,
          );
        },
        child: const Text('Release to seller'),
      ),
    ];
  }

  static Future<String?> _askText(BuildContext context, String title) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What did the courier say about this parcel?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final text = controller.text.trim();
              Navigator.of(context).pop(text.isEmpty ? null : text);
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  static Future<String?> _askFault(
    BuildContext context, {
    String initial = 'seller',
  }) {
    var fault = initial;
    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Who is at fault?'),
          content: RadioGroup<String>(
            groupValue: fault,
            onChanged: (v) => setState(() => fault = v ?? fault),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(value: 'seller', title: Text('Seller')),
                RadioListTile<String>(value: 'courier', title: Text('Courier')),
                RadioListTile<String>(value: 'buyer', title: Text('Buyer')),
                RadioListTile<String>(
                  value: 'none',
                  title: Text('No one / unclear'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(fault),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    this.detail,
    required this.done,
    this.last = false,
  });

  final String title;
  final String? detail;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.brandCrimson : AppColors.roseDivider;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: done ? color : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!last) Expanded(child: Container(width: 2, color: color)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: done ? AppColors.warmBlack : AppColors.warmTaupe,
                    ),
                  ),
                  if (detail != null && detail!.isNotEmpty)
                    Text(detail!, style: TextStyle(color: AppColors.warmTaupe)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProofImage extends StatelessWidget {
  const _ProofImage({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            ApiConfig.mediaUrl(url),
            width: 140,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: 140,
              height: 100,
              color: AppColors.blushSurface,
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _SellerReportsTab extends StatelessWidget {
  const _SellerReportsTab();

  @override
  Widget build(BuildContext context) {
    return AsyncLoader<List<AdminSellerReport>>(
      loader: AdminApiClient.fetchSellerReports,
      refreshInterval: const Duration(seconds: 15),
      builder: (context, reports, reload) {
        if (reports.isEmpty) {
          return const EmptyState(
            message: 'No delivery problems reported by sellers.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
          itemCount: reports.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) =>
              _SellerReportCard(report: reports[i], reload: reload),
        );
      },
    );
  }
}

class _SellerReportCard extends StatelessWidget {
  const _SellerReportCard({required this.report, required this.reload});

  final AdminSellerReport report;
  final VoidCallback reload;

  Widget _statusPill() {
    if (report.isResolved) {
      return StatusPill(
        label: report.resolution == 'refunded' ? 'Refunded' : 'Resolved',
        tone: PillTone.success,
      );
    }
    if (report.isRefundPending) {
      return const StatusPill(label: 'Refund pending', tone: PillTone.warning);
    }
    return const StatusPill(label: 'Open', tone: PillTone.warning);
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().add_jm().format(report.createdAt.toLocal());
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => _SellerReportDialog(report: report, reload: reload),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${report.reasonLabel}  ·  $date',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.warmTaupe,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (report.photoUrls.isNotEmpty) ...[
                const SizedBox(width: 12),
                Icon(
                  Icons.photo_library_outlined,
                  size: 16,
                  color: AppColors.warmTaupe,
                ),
                const SizedBox(width: 4),
                Text(
                  '${report.photoUrls.length}',
                  style: TextStyle(color: AppColors.warmTaupe, fontSize: 13),
                ),
              ],
              const SizedBox(width: 12),
              _statusPill(),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.warmTaupe),
            ],
          ),
        ),
      ),
    );
  }
}

class _SellerReportDialog extends StatelessWidget {
  const _SellerReportDialog({required this.report, required this.reload});

  final AdminSellerReport report;
  final VoidCallback reload;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMd().add_jm();

    void done() {
      Navigator.of(context).pop();
      reload();
    }

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      report.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seller: ${report.sellerName}\n'
                      'Buyer: ${report.buyerName}\n'
                      'Reported: ${fmt.format(report.createdAt.toLocal())}',
                      style: TextStyle(
                        color: AppColors.warmTaupe,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      report.reasonLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (report.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(report.note),
                    ],
                    if (report.photoUrls.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final url in report.photoUrls)
                            InkWell(
                              onTap: () => showPhotoViewer(
                                context,
                                ApiConfig.mediaUrl(url),
                              ),
                              child: _ProofImage(label: 'Screenshot', url: url),
                            ),
                        ],
                      ),
                    ],
                    if (report.isRefundPending &&
                        report.refundDueAt != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Order cancelled. The buyer is refunded automatically '
                        'on ${fmt.format(report.refundDueAt!.toLocal())}.',
                        style: TextStyle(
                          color: AppColors.warmTaupe,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  MessageUserButton(
                    userId: report.buyerId,
                    label: 'Message buyer',
                  ),
                  MessageUserButton(
                    userId: report.sellerId,
                    label: 'Message seller',
                  ),
                  if (report.canRefund && !report.isRefundPending)
                    TextButton(
                      onPressed: () => confirmAndRun(
                        context,
                        title: 'Cancel order & refund buyer?',
                        message:
                            'Use this when the delivery service confirms the '
                            'parcel was lost or damaged. The order is cancelled '
                            'and the buyer\'s money is returned automatically '
                            'in 3 days.',
                        confirmLabel: 'Cancel & refund',
                        action: () => AdminApiClient.refundBuyerForSellerReport(
                          report.id,
                          immediate: false,
                        ),
                        onSuccess: done,
                      ),
                      child: const Text('Cancel & refund buyer'),
                    ),
                  if (report.canRefund && report.isRefundPending)
                    TextButton(
                      onPressed: () => confirmAndRun(
                        context,
                        title: 'Refund the buyer now?',
                        message:
                            'Skips the waiting period and returns the money to '
                            'the buyer immediately.',
                        confirmLabel: 'Refund now',
                        action: () => AdminApiClient.refundBuyerForSellerReport(
                          report.id,
                          immediate: true,
                        ),
                        onSuccess: done,
                      ),
                      child: const Text('Refund now'),
                    ),
                  if (!report.isResolved && !report.isRefundPending)
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.trustGreen,
                      ),
                      onPressed: () => confirmAndRun(
                        context,
                        title: 'Mark as resolved?',
                        message:
                            'Confirm you have looked into this report and updated the buyer.',
                        confirmLabel: 'Resolve',
                        action: () =>
                            AdminApiClient.resolveSellerReport(report.id),
                        onSuccess: done,
                      ),
                      child: const Text('Mark resolved'),
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

class _CoBuyLeavesTab extends StatelessWidget {
  const _CoBuyLeavesTab();

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: r'$');
    return AsyncLoader<List<AdminCoBuyLeave>>(
      loader: AdminApiClient.fetchCoBuyLeaveRequests,
      refreshInterval: const Duration(seconds: 10),
      builder: (context, requests, reload) {
        if (requests.isEmpty) {
          return const EmptyState(
            message: 'No co-buy leave requests from buyers yet.',
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Card(
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      dataRowMaxHeight: 72,
                      columns: const [
                        DataColumn(label: Text('DEAL')),
                        DataColumn(label: Text('BUYER')),
                        DataColumn(label: Text('REFUND')),
                        DataColumn(
                          label: Text('REASON'),
                          columnWidth: FlexColumnWidth(),
                        ),
                        DataColumn(label: Text('REQUESTED')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: [
                        for (final request in requests)
                          DataRow(
                            cells: [
                              DataCell(
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 200,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request.productName,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        request.sellerName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.warmTaupe,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              DataCell(Text(request.buyerName)),
                              DataCell(
                                Text(
                                  '${currency.format(request.amount)} · ${request.quantity} qty',
                                ),
                              ),
                              DataCell(
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 320,
                                  ),
                                  child: Text(
                                    request.adminNote == null
                                        ? request.reason
                                        : '${request.reason}\nAdmin note: ${request.adminNote}',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  DateFormat.yMMMd().format(
                                    request.requestedAt.toLocal(),
                                  ),
                                ),
                              ),
                              DataCell(switch (request.decision) {
                                'approved' => const StatusPill(
                                  label: 'Refunded',
                                  tone: PillTone.success,
                                ),
                                'rejected' => const StatusPill(
                                  label: 'Rejected',
                                  tone: PillTone.neutral,
                                ),
                                _ => const StatusPill(
                                  label: 'Awaiting review',
                                  tone: PillTone.warning,
                                ),
                              }),
                              DataCell(
                                request.isPending
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  AppColors.trustGreen,
                                            ),
                                            onPressed: () => confirmAndRun(
                                              context,
                                              title: 'Approve leave request?',
                                              message:
                                                  'Refund ${currency.format(request.amount)} to ${request.buyerName} and remove them from "${request.productName}".',
                                              confirmLabel: 'Approve',
                                              action: () =>
                                                  AdminApiClient.approveCoBuyLeave(
                                                    request.id,
                                                  ),
                                              onSuccess: reload,
                                            ),
                                            child: const Text('Approve'),
                                          ),
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              foregroundColor: const Color(
                                                0xFFB3261E,
                                              ),
                                            ),
                                            onPressed: () => _rejectWithNote(
                                              context,
                                              request,
                                              reload,
                                            ),
                                            child: const Text('Reject'),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        '-',
                                        style: TextStyle(
                                          color: AppColors.warmTaupe,
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
    );
  }

  Future<void> _rejectWithNote(
    BuildContext context,
    AdminCoBuyLeave request,
    VoidCallback reload,
  ) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject leave request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${request.buyerName} stays in "${request.productName}" and their payment stays in escrow. The reason below is shown to them.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Reason for rejecting',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    final note = controller.text;
    controller.dispose();
    if (confirmed != true || !context.mounted) return;
    try {
      await AdminApiClient.rejectCoBuyLeave(request.id, note);
      reload();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }
}
