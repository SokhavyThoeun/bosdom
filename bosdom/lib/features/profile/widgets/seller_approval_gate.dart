import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../providers/profile_provider.dart';

/// Routes that let a seller list/publish something — blocked until admin
/// approval (`UserProfile.isVerifiedSeller`) so a freshly-registered seller
/// can't sell before KYC review, while every buyer-facing route stays open.
const kSellerOnlyGatedRoutes = {'addListing', 'coBuyDeals'};

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
