import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/hourglass_icon.dart';
import '../providers/profile_provider.dart';

/// Routes that let a seller list/publish something — blocked until admin
/// approval (`UserProfile.isVerifiedSeller`) so a freshly-registered seller
/// can't sell before KYC review, while every buyer-facing route stays open.
const kSellerOnlyGatedRoutes = {
  'sellerDashboard',
  'shopProfile',
  'myInventory',
  'addListing',
  'coBuyDeals',
  'storeAddressBook',
  'sellerOrders',
};

bool isSellerActionGated(WidgetRef ref, String? route) {
  if (route == null || !kSellerOnlyGatedRoutes.contains(route)) return false;
  final profile = ref.read(profileProvider).value;
  return profile != null && !profile.isVerifiedSeller;
}

/// Explains why a not-yet-approved seller can't reach a selling screen, with
/// a resubmit shortcut when the KYC review came back rejected.
void showSellerApprovalPendingDialog(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  final status = ref.read(profileProvider).value?.verificationStatus;
  final rejected = status == 'rejected';

  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(
        rejected
            ? l10n.sellerApprovalRejectedTitle
            : l10n.sellerApprovalPendingTitle,
      ),
      content: Text(
        rejected
            ? l10n.sellerApprovalRejectedMessage
            : l10n.sellerApprovalPendingMessage,
      ),
      actions: [
        if (rejected)
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              dialogContext.pushNamed('becomeSeller');
            },
            child: Text(l10n.sellerApprovalResubmitAction),
          ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.sellerApprovalGotItAction),
        ),
      ],
    ),
  );
}

/// Shown right after a seller registration is submitted, before the account
/// is approved. Awaits the dialog so the caller can navigate afterwards.
Future<void> showSellerAwaitingApprovalDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AlertDialog(
      // AlertDialog lays its icon out in a CrossAxisAlignment.stretch
      // Column, which force-stretches width all the way to the dialog's
      // width. A plain Icon hides this (its glyph is a fixed-size font
      // render, centered in the now-invisibly-wide box), but HourglassIcon's
      // CustomPaint scales its drawing off its own box size, so it would
      // balloon to dialog width. Center gives it loose constraints instead,
      // so it sizes itself to `size` like it does everywhere else.
      icon: Center(
        child: HourglassIcon(
          size: 36,
          color: Theme.of(dialogContext).colorScheme.primary,
        ),
      ),
      title: Text(l10n.sellerApprovalPendingTitle),
      content: Text(l10n.sellerApprovalPendingMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.sellerApprovalGotItAction),
        ),
      ],
    ),
  );
}
