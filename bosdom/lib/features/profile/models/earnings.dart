import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../orders/models/order.dart';
import 'seller_order.dart';

/// Where a sale's payout sits in the escrow lifecycle, derived from the real
/// order's status plus whether the seller has asked the admin to release it.
enum EarningsStatus { inEscrow, releaseRequested, released, disputed, refunded }

String earningsStatusLabel(AppLocalizations l10n, EarningsStatus status) =>
    switch (status) {
      EarningsStatus.inEscrow => l10n.sellerEarningsStatusInEscrow,
      EarningsStatus.releaseRequested =>
        l10n.sellerEarningsStatusReleaseRequested,
      EarningsStatus.released => l10n.sellerEarningsStatusReleased,
      EarningsStatus.disputed => l10n.sellerEarningsStatusDisputed,
      EarningsStatus.refunded => l10n.sellerEarningsRefundedLabel,
    };

/// One row in the seller's earnings ledger: a real paid order, with the
/// gross [saleAmount] the platform fee is cut from.
class EarningsTransaction {
  const EarningsTransaction({
    required this.orderId,
    required this.displayNumber,
    required this.date,
    required this.status,
    required this.buyerName,
    required this.saleAmount,
    this.payoutRequestedAt,
    this.payoutEtaAt,
    this.platformFeeRate = kSellerPlatformFeeRate,
  });

  /// `null` for orders that never reached escrow (unpaid or cancelled), which
  /// have no money to show in an earnings ledger.
  static EarningsTransaction? fromOrder(Order order) {
    final status = switch (order.status) {
      OrderStatus.held =>
        order.releaseRequestedAt != null
            ? EarningsStatus.releaseRequested
            : EarningsStatus.inEscrow,
      OrderStatus.released => EarningsStatus.released,
      OrderStatus.disputed => EarningsStatus.disputed,
      OrderStatus.refunded => EarningsStatus.refunded,
      OrderStatus.pendingPayment || OrderStatus.cancelled => null,
    };
    if (status == null) return null;
    return EarningsTransaction(
      orderId: order.id,
      displayNumber: order.displayNumber,
      date: DateFormat.yMMMd().add_jm().format(
        (order.paidAt ?? order.createdAt).toLocal(),
      ),
      status: status,
      buyerName: order.shippingName,
      saleAmount: order.totalAmount,
      payoutRequestedAt: order.payoutRequestedAt,
      payoutEtaAt: order.payoutEtaAt,
      platformFeeRate: order.platformFee != null && order.totalAmount > 0
          ? order.platformFee! / order.totalAmount
          : kSellerPlatformFeeRate,
    );
  }

  final String orderId;
  final String displayNumber;
  final String date;
  final EarningsStatus status;
  final String buyerName;
  final double saleAmount;
  final double platformFeeRate;
  final DateTime? payoutRequestedAt;
  final DateTime? payoutEtaAt;

  double get platformFee => saleAmount * platformFeeRate;

  /// What the seller actually keeps after the platform fee.
  double get netAmount => saleAmount - platformFee;

  /// Still sitting in escrow (whether or not release has been requested).
  bool get isHeld =>
      status == EarningsStatus.inEscrow ||
      status == EarningsStatus.releaseRequested;
}

/// Totals for the balance card and stat tiles, computed from real orders.
class EarningsSummary {
  EarningsSummary(this.transactions)
    : releasedTotal = _sum(transactions, EarningsStatus.released),
      inEscrowTotal =
          _sum(transactions, EarningsStatus.inEscrow) +
          _sum(transactions, EarningsStatus.releaseRequested),
      refundedTotal = transactions
          .where((t) => t.status == EarningsStatus.refunded)
          .fold(0.0, (sum, t) => sum + t.saleAmount);

  final List<EarningsTransaction> transactions;
  final double releasedTotal;
  final double inEscrowTotal;
  final double refundedTotal;

  static double _sum(List<EarningsTransaction> all, EarningsStatus status) =>
      all
          .where((t) => t.status == status)
          .fold(0.0, (sum, t) => sum + t.netAmount);

  /// Released money (the buyer got the item) the seller hasn't withdrawn yet.
  double get availableBalance => transactions
      .where(
        (t) =>
            t.status == EarningsStatus.released && t.payoutRequestedAt == null,
      )
      .fold(0.0, (sum, t) => sum + t.netAmount);

  /// Withdrawals the seller has requested that the admin hasn't approved yet.
  double get pendingApprovalTotal => transactions
      .where(
        (t) =>
            t.status == EarningsStatus.released &&
            t.payoutRequestedAt != null &&
            t.payoutEtaAt == null,
      )
      .fold(0.0, (sum, t) => sum + t.netAmount);

  /// Approved money whose bank transfer hasn't landed yet.
  double arrivingTotal(DateTime now) =>
      _arriving(now).fold(0.0, (sum, t) => sum + t.netAmount);

  /// When the last pending transfer is due, or `null` if none is on its way.
  DateTime? arrivingBy(DateTime now) {
    DateTime? latest;
    for (final t in _arriving(now)) {
      final eta = t.payoutEtaAt!;
      if (latest == null || eta.isAfter(latest)) latest = eta;
    }
    return latest;
  }

  Iterable<EarningsTransaction> _arriving(DateTime now) => transactions.where(
    (t) =>
        t.status == EarningsStatus.released &&
        t.payoutEtaAt != null &&
        t.payoutEtaAt!.isAfter(now),
  );

  int get completedSalesPercent {
    final settled = transactions
        .where((t) => t.status != EarningsStatus.refunded)
        .length;
    if (settled == 0) return 0;
    final released = transactions
        .where((t) => t.status == EarningsStatus.released)
        .length;
    return (released * 100 / settled).round();
  }
}
