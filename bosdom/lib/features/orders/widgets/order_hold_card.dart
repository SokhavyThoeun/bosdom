import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/order.dart';

/// Human-readable label for an order hold reason code. `forSeller` swaps the
/// wording that only makes sense from the buyer's point of view.
String orderHoldReasonLabel(
  AppLocalizations l10n,
  String code, {
  bool forSeller = false,
}) => switch (code) {
  'delivery_delayed' => l10n.orderHoldReasonDeliveryDelayed,
  'parcel_lost_or_damaged' => l10n.orderHoldReasonLostOrDamaged,
  'buyer_unreachable' =>
    forSeller
        ? l10n.orderHoldReasonBuyerUnreachableSeller
        : l10n.orderHoldReasonBuyerUnreachable,
  'address_problem' => l10n.orderHoldReasonAddress,
  'wrong_item' => l10n.orderHoldReasonWrongItem,
  'damaged' => l10n.orderHoldReasonDamaged,
  'missing' => l10n.orderHoldReasonMissing,
  'late_delivery' => l10n.orderHoldReasonLate,
  _ => l10n.orderHoldReasonOther,
};

/// Tells the buyer why a disputed order is on hold and when they get their
/// money back. Renders nothing for orders that aren't disputed.
class OrderHoldCard extends StatelessWidget {
  const OrderHoldCard({super.key, required this.order, this.forSeller = false});

  final Order order;

  /// Seller view: shows only that BosDom Support cancelled the order, with no
  /// refund details (those are for the buyer).
  final bool forSeller;

  @override
  Widget build(BuildContext context) {
    final source = order.holdSource;
    if (order.status != OrderStatus.disputed || source == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final due = order.refundDueAt;
    final body = forSeller
        ? l10n.orderHoldSellerBody
        : source == 'delivery' && due != null
        ? l10n.orderHoldDeliveryBody(DateFormat.yMMMd().format(due.toLocal()))
        : l10n.orderHoldBuyerBody;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.orderHoldTitle,
            style: textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          if (order.holdReason != null)
            Text(
              orderHoldReasonLabel(
                l10n,
                order.holdReason!,
                forSeller: forSeller,
              ),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (order.holdNote != null && !forSeller) ...[
            const SizedBox(height: 2),
            Text(
              order.holdNote!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            body,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
