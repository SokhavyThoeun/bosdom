import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/delivery_carrier.dart';

/// The courier delivering an order — its logo, name and, once shipped, the
/// tracking number. Body of the "Delivery Method" card on both the buyer and
/// seller order detail screens.
class OrderCarrierRow extends StatelessWidget {
  const OrderCarrierRow({
    super.key,
    required this.courier,
    this.trackingNumber,
  });

  final String courier;
  final String? trackingNumber;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final logoAsset = deliveryLogoAsset(courier);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: logoAsset != null
                ? Image.asset(
                    logoAsset,
                    width: 56,
                    height: 42,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 56,
                    height: 42,
                    alignment: Alignment.center,
                    color: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.local_shipping_outlined,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderDetailCarrierLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  courier,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (trackingNumber != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.escrowTrackingNumberLabel}: $trackingNumber',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
