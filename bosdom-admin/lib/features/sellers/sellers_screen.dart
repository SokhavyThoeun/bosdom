import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;

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

class SellersScreen extends StatefulWidget {
  const SellersScreen({super.key});

  @override
  State<SellersScreen> createState() => _SellersScreenState();
}

/// Triggers a browser download of everything the seller submitted, as a
/// plain-text file, so admins can save a record of what was reviewed.
void _downloadSellerInfo(AdminSeller seller) {
  final buffer = StringBuffer()
    ..writeln('SELLER')
    ..writeln('Name: ${seller.name}')
    ..writeln('Email: ${seller.email}')
    ..writeln('Phone: ${seller.phone}')
    ..writeln('Verification status: ${seller.verificationStatus}')
    ..writeln('Suspended: ${seller.isSuspended ? 'Yes' : 'No'}')
    ..writeln('Joined: ${DateFormat.yMMMd().format(seller.createdAt)}')
    ..writeln()
    ..writeln('BUSINESS INFO')
    ..writeln('Business type: ${seller.shopBusinessType}')
    ..writeln('Type of store: ${seller.shopStoreType}')
    ..writeln('Year established: ${seller.shopYearEstablished}')
    ..writeln('Location: ${seller.shopLocation}')
    ..writeln('Shop phone: ${seller.shopPhone}')
    ..writeln('Shop email: ${seller.shopEmail}');
  if (seller.shopStoreUrl.isNotEmpty) {
    buffer.writeln('Online store URL: ${seller.shopStoreUrl}');
  }
  buffer
    ..writeln()
    ..writeln('DESCRIPTION')
    ..writeln(
      seller.shopDescription.isEmpty
          ? 'No description provided.'
          : seller.shopDescription,
    )
    ..writeln()
    ..writeln('STORE PHOTOS');
  if (seller.shopPhotoUrls.isEmpty) {
    buffer.writeln('None uploaded');
  } else {
    for (final url in seller.shopPhotoUrls) {
      buffer.writeln('${ApiConfig.baseUrl}$url');
    }
  }
  buffer
    ..writeln()
    ..writeln('KYC DOCUMENTS');
  if (seller.kycDocuments.isEmpty) {
    buffer.writeln('None uploaded');
  } else {
    for (final doc in seller.kycDocuments) {
      buffer.writeln('${doc.docType}: ${ApiConfig.baseUrl}${doc.fileUrl}');
    }
  }

  final blob = web.Blob(
    [buffer.toString().toJS].toJS,
    web.BlobPropertyBag(type: 'text/plain'),
  );
  final url = web.URL.createObjectURL(blob);
  final slug = (seller.shopName.isEmpty ? seller.name : seller.shopName)
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'(^-+)|(-+$)'), '');
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = 'seller-${slug.isEmpty ? seller.id : slug}.txt';
  web.document.body!.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

class _SellersScreenState extends State<SellersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminPageHeader(
          title: 'Sellers & Shops',
          subtitle: 'Review KYC, verify sellers, suspend bad actors',
          actions: [
            SizedBox(
              width: 280,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search sellers...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  isDense: true,
                ),
                onChanged: (value) =>
                    setState(() => _query = value.trim().toLowerCase()),
              ),
            ),
          ],
        ),
        Expanded(
          child: AsyncLoader<List<AdminSeller>>(
            loader: AdminApiClient.fetchSellers,
            builder: (context, sellers, reload) {
              final filtered = _query.isEmpty
                  ? sellers
                  : sellers
                        .where(
                          (s) =>
                              s.name.toLowerCase().contains(_query) ||
                              s.shopName.toLowerCase().contains(_query) ||
                              s.email.toLowerCase().contains(_query),
                        )
                        .toList();

              if (filtered.isEmpty) {
                return const EmptyState(message: 'No sellers found.');
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                child: SizedBox(
                  width: double.infinity,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        dataRowMinHeight: 52,
                        dataRowMaxHeight: double.infinity,
                        columns: const [
                          DataColumn(label: Text('SHOP')),
                          DataColumn(label: Text('SELLER')),
                          DataColumn(label: Text('CONTACT')),
                          DataColumn(label: Text('STORE PHOTOS')),
                          DataColumn(label: Text('KYC DOCS')),
                          DataColumn(label: Text('VERIFICATION')),
                          DataColumn(label: Text('ACCOUNT')),
                          DataColumn(label: Text('JOINED')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: [
                          for (final seller in filtered)
                            DataRow(
                              cells: [
                                DataCell(
                                  InkWell(
                                    onTap: () => showDialog<void>(
                                      context: context,
                                      builder: (_) => _SellerReviewDialog(
                                        seller: seller,
                                        reload: reload,
                                      ),
                                    ),
                                    child: Text(
                                      seller.shopName.isEmpty
                                          ? '-'
                                          : seller.shopName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.warmTaupe,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(seller.name)),
                                DataCell(
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        seller.email,
                                        style: const TextStyle(fontSize: 12.5),
                                      ),
                                      Text(
                                        seller.phone,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.warmTaupe,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  _StorePhotosCell(
                                    photoUrls: seller.shopPhotoUrls,
                                  ),
                                ),
                                DataCell(
                                  _KycDocsCell(documents: seller.kycDocuments),
                                ),
                                DataCell(
                                  StatusPill.verification(
                                    seller.verificationStatus,
                                  ),
                                ),
                                DataCell(
                                  StatusPill.suspended(seller.isSuspended),
                                ),
                                DataCell(
                                  Text(
                                    DateFormat.yMMMd().format(seller.createdAt),
                                  ),
                                ),
                                DataCell(
                                  _SellerActions(
                                    seller: seller,
                                    reload: reload,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _KycDocsCell extends StatelessWidget {
  const _KycDocsCell({required this.documents});

  final List<AdminKycDocument> documents;

  static const _labels = {
    'national_id': 'National ID',
    'passport': 'Passport',
    'business_certificate': 'Business cert.',
  };

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const Text(
        'None uploaded',
        style: TextStyle(color: AppColors.warmTaupe),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final doc in documents)
          InkWell(
            onTap: () =>
                web.window.open('${ApiConfig.baseUrl}${doc.fileUrl}', '_blank'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                '${_labels[doc.docType] ?? doc.docType}  ↗',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.infoBlue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StorePhotosCell extends StatelessWidget {
  const _StorePhotosCell({required this.photoUrls});

  final List<String> photoUrls;

  @override
  Widget build(BuildContext context) {
    if (photoUrls.isEmpty) {
      return const Text(
        'None uploaded',
        style: TextStyle(color: AppColors.warmTaupe),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final url in photoUrls) ...[
          InkWell(
            onTap: () => showPhotoViewer(context, '${ApiConfig.baseUrl}$url'),
            borderRadius: BorderRadius.circular(6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                '${ApiConfig.baseUrl}$url',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (url != photoUrls.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

/// Everything the seller submitted during registration, in one place, so
/// admin can check it all before approving — not just the KYC docs and
/// photo thumbnails that fit in the table row.
class _SellerReviewDialog extends StatelessWidget {
  const _SellerReviewDialog({required this.seller, required this.reload});

  final AdminSeller seller;
  final VoidCallback reload;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (seller.shopLogoUrl.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${ApiConfig.baseUrl}${seller.shopLogoUrl}',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seller.shopName.isEmpty
                              ? seller.name
                              : seller.shopName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Joined ${DateFormat.yMMMd().format(seller.createdAt)}',
                          style: const TextStyle(
                            color: AppColors.warmTaupe,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusPill.verification(seller.verificationStatus),
                  const SizedBox(width: 8),
                  StatusPill.suspended(seller.isSuspended),
                ],
              ),
              const Divider(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionLabel('SELLER'),
                      _InfoRow('Name', seller.name),
                      _InfoRow('Email', seller.email),
                      _InfoRow('Phone', seller.phone),
                      const SizedBox(height: 20),
                      const _SectionLabel('BUSINESS INFO'),
                      _InfoRow('Business type', seller.shopBusinessType),
                      _InfoRow('Type of store', seller.shopStoreType),
                      _InfoRow('Year established', seller.shopYearEstablished),
                      _InfoRow('Location', seller.shopLocation),
                      _InfoRow('Shop phone', seller.shopPhone),
                      _InfoRow('Shop email', seller.shopEmail),
                      if (seller.shopStoreUrl.isNotEmpty)
                        _InfoRow('Online store URL', seller.shopStoreUrl),
                      const SizedBox(height: 12),
                      Text(
                        seller.shopDescription.isEmpty
                            ? 'No description provided.'
                            : seller.shopDescription,
                        style: const TextStyle(fontSize: 13.5, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      const _SectionLabel('STORE PHOTOS'),
                      if (seller.shopPhotoUrls.isEmpty)
                        const Text(
                          'None uploaded',
                          style: TextStyle(color: AppColors.warmTaupe),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final url in seller.shopPhotoUrls)
                              InkWell(
                                onTap: () => showPhotoViewer(
                                  context,
                                  '${ApiConfig.baseUrl}$url',
                                ),
                                borderRadius: BorderRadius.circular(8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '${ApiConfig.baseUrl}$url',
                                    width: 88,
                                    height: 88,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      const _SectionLabel('KYC DOCUMENTS'),
                      _KycDocsCell(documents: seller.kycDocuments),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                      TextButton.icon(
                        onPressed: () => _downloadSellerInfo(seller),
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Download'),
                      ),
                    ],
                  ),
                  _SellerActions(
                    seller: seller,
                    showReview: false,
                    reload: () {
                      Navigator.of(context).pop();
                      reload();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.warmTaupe,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.warmTaupe,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerActions extends StatelessWidget {
  const _SellerActions({
    required this.seller,
    required this.reload,
    this.showReview = true,
  });

  final AdminSeller seller;
  final VoidCallback reload;
  final bool showReview;

  @override
  Widget build(BuildContext context) {
    final status = seller.verificationStatus;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MessageUserButton(userId: seller.id),
        if (showReview)
          TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) =>
                  _SellerReviewDialog(seller: seller, reload: reload),
            ),
            child: const Text('Review'),
          ),
        if (status != 'verified')
          TextButton(
            onPressed: () => confirmAndRun(
              context,
              title: 'Approve seller?',
              message: '${seller.name} will be marked as a verified seller.',
              confirmLabel: 'Approve',
              action: () => AdminApiClient.verifyProfile(seller.id),
              onSuccess: reload,
            ),
            child: const Text('Approve'),
          ),
        if (status == 'pending')
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB3261E),
            ),
            onPressed: () => _rejectWithReason(context, seller, reload),
            child: const Text('Reject'),
          ),
        if (status == 'verified')
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB3261E),
            ),
            onPressed: () => confirmAndRun(
              context,
              title: 'Revoke verification?',
              message: '${seller.name} will lose their verified seller badge.',
              confirmLabel: 'Revoke',
              destructive: true,
              action: () => AdminApiClient.unverifyProfile(seller.id),
              onSuccess: reload,
            ),
            child: const Text('Revoke'),
          ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: seller.isSuspended
                ? AppColors.trustGreen
                : const Color(0xFFB3261E),
          ),
          onPressed: () => confirmAndRun(
            context,
            title: seller.isSuspended ? 'Unsuspend seller?' : 'Suspend seller?',
            message: seller.isSuspended
                ? '${seller.name} will regain access to the app.'
                : '${seller.name} will be blocked from the app immediately.',
            confirmLabel: seller.isSuspended ? 'Unsuspend' : 'Suspend',
            destructive: !seller.isSuspended,
            action: () => seller.isSuspended
                ? AdminApiClient.unsuspendProfile(seller.id)
                : AdminApiClient.suspendProfile(seller.id),
            onSuccess: reload,
          ),
          child: Text(seller.isSuspended ? 'Unsuspend' : 'Suspend'),
        ),
      ],
    );
  }
}

/// Asks for the reason first: it is sent to the seller as a notification so
/// they know what to fix before registering again.
Future<void> _rejectWithReason(
  BuildContext context,
  AdminSeller seller,
  VoidCallback reload,
) async {
  final controller = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) => AlertDialog(
        title: const Text('Reject seller?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${seller.name} goes back to a normal buyer account and can '
              'register as a seller again. The reason below is sent to them.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Reason for rejecting',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: controller.text.trim().isEmpty
                ? null
                : () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reject'),
          ),
        ],
      ),
    ),
  );
  final reason = controller.text.trim();
  controller.dispose();
  if (confirmed != true || !context.mounted) return;
  try {
    await AdminApiClient.rejectProfile(seller.id, reason);
    reload();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reject done')));
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
