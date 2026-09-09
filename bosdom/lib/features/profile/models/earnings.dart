import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'seller_order.dart';

/// Where a payout sits in the escrow lifecycle. Independent of
/// [SellerOrderStatus] (which tracks fulfillment) since a sale can be
/// released or disputed well after it ships.
enum EarningsStatus { pending, inEscrow, released, disputed, withdrawn }

String earningsStatusLabel(AppLocalizations l10n, EarningsStatus status) =>
    switch (status) {
      EarningsStatus.pending => l10n.sellerEarningsStatusPending,
      EarningsStatus.inEscrow => l10n.sellerEarningsStatusInEscrow,
      EarningsStatus.released => l10n.sellerEarningsStatusReleased,
      EarningsStatus.disputed => l10n.sellerEarningsStatusDisputed,
      EarningsStatus.withdrawn => l10n.sellerEarningsStatusWithdrawn,
    };

Color earningsStatusColor(EarningsStatus status) => switch (status) {
  EarningsStatus.pending => AppColors.alertAmber,
  EarningsStatus.inEscrow => AppColors.alertAmber,
  EarningsStatus.released => AppColors.trustGreen,
  EarningsStatus.disputed => AppColors.brandCrimson,
  EarningsStatus.withdrawn => AppColors.warmTaupe,
};

/// One row in the seller's earnings ledger: either a sale payout (tied to
/// an order, with a gross [saleAmount] the platform fee is cut from) or a
/// withdrawal to the seller's bank account.
class EarningsTransaction {
  const EarningsTransaction.sale({
    required this.id,
    required this.date,
    required this.status,
    required this.buyerName,
    required double saleAmount,
    this.platformFeeRate = kSellerPlatformFeeRate,
  }) : _saleAmount = saleAmount,
       _withdrawalAmount = null,
       withdrawalMethod = null;

  const EarningsTransaction.withdrawal({
    required this.id,
    required this.date,
    required double amount,
    required this.withdrawalMethod,
  }) : status = EarningsStatus.withdrawn,
       buyerName = null,
       _saleAmount = null,
       _withdrawalAmount = amount,
       platformFeeRate = 0.0;

  final String id;
  final String date;
  final EarningsStatus status;
  final String? buyerName;
  final double? _saleAmount;
  final double? _withdrawalAmount;
  final double platformFeeRate;
  final String? withdrawalMethod;

  bool get isWithdrawal => _withdrawalAmount != null;

  /// Gross sale amount before the platform fee — `null` for a withdrawal.
  double? get saleAmount => _saleAmount;

  double get platformFee => (_saleAmount ?? 0) * platformFeeRate;

  /// Signed amount this row moves the seller's balance by: a sale's net
  /// payout, or a withdrawal shown as a negative.
  double get signedAmount =>
      isWithdrawal ? -_withdrawalAmount! : _saleAmount! - platformFee;
}

final kMockEarningsTransactions = [
  EarningsTransaction.sale(
    id: 'BD-98402',
    date: 'Oct 28, 2025 at 9:14 AM',
    status: EarningsStatus.pending,
    buyerName: 'Sokhavy Thoeun',
    saleAmount: 2083.33,
  ),
  EarningsTransaction.withdrawal(
    id: 'WD-20251027',
    date: 'Oct 27, 2025 at 11:42 AM',
    amount: 640.00,
    withdrawalMethod: 'ABA Bank ****982',
  ),
  EarningsTransaction.sale(
    id: 'BD-98399',
    date: 'Oct 26, 2025 at 3:30 PM',
    status: EarningsStatus.released,
    buyerName: 'Vannak Khorn',
    saleAmount: 25000.00,
  ),
  EarningsTransaction.sale(
    id: 'BD-98390',
    date: 'Oct 25, 2025 at 2:00 PM',
    status: EarningsStatus.released,
    buyerName: 'Phnom Penh Grocers',
    saleAmount: 3422.22,
  ),
];

const kMockAvailableBalance = 1240.00;
const kMockCompletedSalesPercent = 80;
const kMockReleasedTotal = 1240.00;
const kMockInEscrowTotal = 180.00;
const kMockRefundedTotal = 0.00;
