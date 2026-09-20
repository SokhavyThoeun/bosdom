import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../services/order_service.dart';

const _kMaxPhotos = 6;

/// Opens the "Rate & Review" bottom sheet for [order]'s product. Resolves
/// once the sheet is dismissed. There's no seller display name on a real
/// order (`OrderOut` only carries `seller_id`), so this only rates the
/// product, not a separate "rate the store" card.
Future<void> showRateReviewSheet(BuildContext context, Order order) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _RateReviewSheet(order: order),
  );
}

class _RateReviewSheet extends ConsumerStatefulWidget {
  const _RateReviewSheet({required this.order});

  final Order order;

  @override
  ConsumerState<_RateReviewSheet> createState() => _RateReviewSheetState();
}

class _RateReviewSheetState extends ConsumerState<_RateReviewSheet> {
  int _productRating = 0;
  final _reviewController = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _photos = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _addPhotos() async {
    final l10n = AppLocalizations.of(context);
    final remaining = _kMaxPhotos - _photos.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reviewMaxPhotosSnackbar(_kMaxPhotos))),
      );
      return;
    }
    try {
      final picked = await _picker.pickMultiImage(limit: remaining);
      if (picked.isEmpty || !mounted) return;
      setState(() => _photos.addAll(picked));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reviewPhotoLibraryErrorSnackbar('$e'))),
      );
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_productRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reviewRatingRequiredSnackbar)),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final orderId = widget.order.id;
      await OrderService.submitReview(
        orderId: orderId,
        rating: _productRating,
        comment: _reviewController.text.trim(),
        photoPaths: _photos.map((photo) => photo.path).toList(),
      );
      ref.invalidate(orderByIdProvider(orderId));
      ref.invalidate(ordersProvider);
      ref.invalidate(sellerOrdersProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.reviewSubmittedSnackbar)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.reviewSubmitFailedSnackbar('$e'))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final order = widget.order;

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
                        l10n.reviewSheetTitle,
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
                const SizedBox(height: 18),
                _RatingCard(
                  label: l10n.reviewRateProductLabel,
                  icon: order.icon,
                  imageUrl: order.imageUrl,
                  name: order.productName,
                  sellerName: order.sellerName,
                  sellerLogoUrl: order.sellerLogoUrl,
                  rating: _productRating,
                  onChanged: (value) => setState(() => _productRating = value),
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.reviewWriteReviewLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _reviewController,
                  maxLines: 3,
                  decoration: InputDecoration(hintText: l10n.reviewHintText),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.reviewAddPhotosLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 72,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      InkWell(
                        onTap: _addPhotos,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 72,
                          height: 72,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.primary.withValues(
                                alpha: 0.45,
                              ),
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.reviewAddPhotosButton,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9.5,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      for (final photo in _photos) ...[
                        const SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(photo.path),
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
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
                        : Text(l10n.reviewSubmitButton),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.label,
    required this.icon,
    required this.imageUrl,
    required this.name,
    required this.sellerName,
    required this.sellerLogoUrl,
    required this.rating,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final IconData icon;
  final String? imageUrl;
  final String name;
  final String? sellerName;
  final String? sellerLogoUrl;
  final int rating;
  final ValueChanged<int> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: (imageUrl == null || imageUrl!.isEmpty)
                      ? Container(
                          color: colorScheme.primaryContainer,
                          alignment: Alignment.center,
                          child: Icon(
                            icon,
                            size: 17,
                            color: colorScheme.primary,
                          ),
                        )
                      : Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: colorScheme.primaryContainer,
                                alignment: Alignment.center,
                                child: Icon(
                                  icon,
                                  size: 17,
                                  color: colorScheme.primary,
                                ),
                              ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (sellerName != null && sellerName!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child:
                                  (sellerLogoUrl == null ||
                                      sellerLogoUrl!.isEmpty)
                                  ? Container(
                                      color: colorScheme.primaryContainer,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.storefront_outlined,
                                        size: 10,
                                        color: colorScheme.primary,
                                      ),
                                    )
                                  : Image.network(
                                      sellerLogoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => Container(
                                            color: colorScheme.primaryContainer,
                                            alignment: Alignment.center,
                                            child: Icon(
                                              Icons.storefront_outlined,
                                              size: 10,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              sellerName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 5; i++)
                _StarButton(
                  filled: i < rating,
                  onTap: () => onChanged(i + 1 == rating ? 0 : i + 1),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A single tappable star with a full 44x44 hit target (icon-only bounds are
/// too small to hit reliably) and an immediate press-scale so taps feel
/// responsive instead of laggy.
class _StarButton extends StatefulWidget {
  const _StarButton({required this.filled, required this.onTap});

  final bool filled;
  final VoidCallback onTap;

  @override
  State<_StarButton> createState() => _StarButtonState();
}

class _StarButtonState extends State<_StarButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: AnimatedScale(
            scale: _pressed ? 0.78 : 1.0,
            duration: const Duration(milliseconds: 90),
            curve: Curves.easeOut,
            child: Icon(
              widget.filled ? Icons.star_rounded : Icons.star_border_rounded,
              size: 28,
              color: Colors.amber.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
