import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A single small colored badge — the only place color shows up in an
/// otherwise black/white admin table row (mirrors the mobile app's list
/// styling convention).
class StatusPill extends StatelessWidget {
  const StatusPill({required this.label, required this.tone, super.key});

  factory StatusPill.verification(String status) {
    switch (status) {
      case 'verified':
        return StatusPill(label: 'Verified', tone: PillTone.success);
      case 'pending':
        return StatusPill(label: 'Pending review', tone: PillTone.warning);
      case 'rejected':
        return StatusPill(label: 'Rejected', tone: PillTone.danger);
      default:
        return StatusPill(label: 'Unverified', tone: PillTone.neutral);
    }
  }

  factory StatusPill.suspended(bool isSuspended) => isSuspended
      ? const StatusPill(label: 'Suspended', tone: PillTone.danger)
      : const StatusPill(label: 'Active', tone: PillTone.success);

  factory StatusPill.listing(bool active) => active
      ? const StatusPill(label: 'Live', tone: PillTone.success)
      : const StatusPill(label: 'Taken down', tone: PillTone.danger);

  factory StatusPill.orderStatus(String status) {
    switch (status) {
      case 'released':
        return const StatusPill(label: 'Released', tone: PillTone.success);
      case 'refunded':
        return const StatusPill(label: 'Refunded', tone: PillTone.neutral);
      case 'cancelled':
        return const StatusPill(label: 'Cancelled', tone: PillTone.neutral);
      case 'disputed':
        return const StatusPill(label: 'Disputed', tone: PillTone.danger);
      case 'held':
        return const StatusPill(label: 'Held (escrow)', tone: PillTone.info);
      default:
        return const StatusPill(
          label: 'Pending payment',
          tone: PillTone.warning,
        );
    }
  }

  factory StatusPill.disputeStatus(String status) {
    switch (status) {
      case 'resolved':
        return const StatusPill(label: 'Resolved', tone: PillTone.success);
      case 'case_open':
        return const StatusPill(label: 'Case open', tone: PillTone.info);
      case 'under_review':
        return const StatusPill(label: 'Evidence in', tone: PillTone.info);
      default:
        return const StatusPill(label: 'Reported', tone: PillTone.warning);
    }
  }

  final String label;
  final PillTone tone;

  Color _bg() => switch (tone) {
    PillTone.success => AppColors.trustGreen.withValues(alpha: 0.12),
    PillTone.danger => AppColors.alertAmber.withValues(alpha: 0.16),
    PillTone.warning => AppColors.ratingGold.withValues(alpha: 0.16),
    PillTone.info => AppColors.infoBlue.withValues(alpha: 0.12),
    PillTone.neutral => AppColors.warmTaupe.withValues(alpha: 0.12),
  };

  Color _fg() => switch (tone) {
    PillTone.success => AppColors.trustGreen,
    PillTone.danger => const Color(0xFFB3261E),
    PillTone.warning => const Color(0xFF8A6100),
    PillTone.info => AppColors.infoBlue,
    PillTone.neutral => AppColors.warmTaupe,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bg(),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _fg(),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

enum PillTone { success, danger, warning, info, neutral }
