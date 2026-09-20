import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/order.dart';
import '../services/order_service.dart';

/// Opens the seller's "Ship order" sheet (parcel photo + courier + tracking
/// number). Resolves `true` once the order was shipped.
Future<bool> showShipOrderSheet(BuildContext context, Order order) async {
  final shipped = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _FulfilmentSheet(order: order, delivering: false),
  );
  return shipped ?? false;
}

/// Opens the seller's "Proof of delivery" sheet — submitting it starts the
/// buyer's review timer. Resolves `true` once the order was marked delivered.
Future<bool> showDeliveryProofSheet(BuildContext context, Order order) async {
  final delivered = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _FulfilmentSheet(order: order, delivering: true),
  );
  return delivered ?? false;
}

class _FulfilmentSheet extends StatefulWidget {
  const _FulfilmentSheet({required this.order, required this.delivering});

  final Order order;
  final bool delivering;

  @override
  State<_FulfilmentSheet> createState() => _FulfilmentSheetState();
}

class _FulfilmentSheetState extends State<_FulfilmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _courierController = TextEditingController();
  final _trackingController = TextEditingController();
  final _picker = ImagePicker();
  String? _photoPath;
  bool _photoMissing = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _courierController.dispose();
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _photoPath = picked.path;
        _photoMissing = false;
      });
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final formValid = widget.delivering || _formKey.currentState!.validate();
    if (_photoPath == null) setState(() => _photoMissing = true);
    if (!formValid || _photoPath == null) return;

    setState(() => _isSubmitting = true);
    try {
      if (widget.delivering) {
        await OrderService.markDelivered(
          orderId: widget.order.id,
          photoPath: _photoPath!,
        );
      } else {
        await OrderService.shipOrder(
          orderId: widget.order.id,
          courier: _courierController.text.trim(),
          trackingNumber: _trackingController.text.trim(),
          photoPath: _photoPath!,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.escrowActionFailed('$e'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Form(
              key: _formKey,
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
                  Text(
                    widget.delivering
                        ? l10n.escrowDeliverySheetTitle
                        : l10n.escrowShipSheetTitle,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.delivering) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.escrowDeliverySheetNote,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _courierController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.escrowCourierLabel,
                        hintText: l10n.escrowCourierHint,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.sellerEarningsWithdrawFieldRequiredError
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _trackingController,
                      decoration: InputDecoration(
                        labelText: l10n.escrowTrackingNumberLabel,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.sellerEarningsWithdrawFieldRequiredError
                          : null,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    widget.delivering
                        ? l10n.escrowDeliverySheetTitle
                        : l10n.escrowParcelPhotoLabel,
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickPhoto,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _photoMissing
                              ? colorScheme.error
                              : colorScheme.outlineVariant,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _photoPath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_a_photo_outlined),
                                const SizedBox(height: 6),
                                Text(
                                  _photoMissing
                                      ? l10n.escrowPhotoRequired
                                      : l10n.escrowAddPhoto,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: _photoMissing
                                        ? colorScheme.error
                                        : null,
                                  ),
                                ),
                              ],
                            )
                          : Image.file(File(_photoPath!), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        : Text(
                            widget.delivering
                                ? l10n.escrowDeliverySubmit
                                : l10n.escrowShipSubmit,
                          ),
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
