import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../models/order.dart';
import '../services/dispute_service.dart';

const _kMaxPhotos = 3;

enum _Reason { delayed, lost, unreachable, address, other }

extension on _Reason {
  String label(AppLocalizations l10n) => switch (this) {
    _Reason.delayed => l10n.sellerReportReasonDelayed,
    _Reason.lost => l10n.sellerReportReasonLost,
    _Reason.unreachable => l10n.sellerReportReasonUnreachable,
    _Reason.address => l10n.sellerReportReasonAddress,
    _Reason.other => l10n.ordersReportReasonOther,
  };

  // Stable key sent to the backend, independent of the localized label.
  String get apiValue => switch (this) {
    _Reason.delayed => 'delivery_delayed',
    _Reason.lost => 'parcel_lost_or_damaged',
    _Reason.unreachable => 'buyer_unreachable',
    _Reason.address => 'address_problem',
    _Reason.other => 'other',
  };
}

/// Opens the seller's "Report a delivery problem" sheet for [order].
Future<void> showSellerReportSheet(BuildContext context, Order order) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SellerReportSheet(order: order),
  );
}

class _SellerReportSheet extends StatefulWidget {
  const _SellerReportSheet({required this.order});

  final Order order;

  @override
  State<_SellerReportSheet> createState() => _SellerReportSheetState();
}

class _SellerReportSheetState extends State<_SellerReportSheet> {
  _Reason _reason = _Reason.delayed;
  final _noteController = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _photos = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _addPhotos() async {
    final remaining = _kMaxPhotos - _photos.length;
    if (remaining <= 0) return;
    try {
      final picked = await _picker.pickMultiImage(
        limit: remaining,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked.isEmpty || !mounted) return;
      setState(() => _photos.addAll(picked.take(remaining)));
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        message: AppLocalizations.of(context).sellerReportFailedSnackbar('$e'),
        type: AppSnackBarType.error,
      );
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSubmitting = true);
    try {
      await DisputeService.reportAsSeller(
        orderId: widget.order.id,
        reason: _reason.apiValue,
        note: _noteController.text.trim(),
        photoPaths: [for (final p in _photos) p.path],
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      showAppSnackBar(
        context,
        message: l10n.sellerReportSubmittedSnackbar,
        type: AppSnackBarType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showAppSnackBar(
        context,
        message: l10n.sellerReportFailedSnackbar('$e'),
        type: AppSnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.sellerReportSheetTitle,
                          style: textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.sellerReportIntro,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.ordersReportReasonLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final reason in _Reason.values)
                        ChoiceChip(
                          label: Text(reason.label(l10n)),
                          selected: _reason == reason,
                          onSelected: (_) => setState(() => _reason = reason),
                          labelStyle: textTheme.labelMedium?.copyWith(
                            color: _reason == reason
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          selectedColor: colorScheme.primary,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide.none,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.ordersReportNoteLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: l10n.ordersReportNoteHint,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.sellerReportPhotosLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final photo in _photos)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(photo.path),
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: -6,
                              right: -6,
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _photos.remove(photo)),
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: colorScheme.primary,
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (_photos.length < _kMaxPhotos)
                        InkWell(
                          onTap: _addPhotos,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.ordersReportSubmitButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
