import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/dotted_border_box.dart';
import '../models/co_buy_session.dart';
import '../providers/co_buy_provider.dart';

const _kMaxPhotos = 4;

enum _Duration {
  oneDay('1 day left'),
  twoDays('2 days left'),
  threeDays('3 days left'),
  fiveDays('5 days left'),
  oneWeek('1 week left');

  const _Duration(this.timeLeftText);

  /// Canonical, locale-independent value stored on the session — matches how
  /// every other mock session's timeLeft string is authored in English.
  final String timeLeftText;

  String label(AppLocalizations l10n) => switch (this) {
    _Duration.oneDay => l10n.coBuyCreateDuration1Day,
    _Duration.twoDays => l10n.coBuyCreateDuration2Days,
    _Duration.threeDays => l10n.coBuyCreateDuration3Days,
    _Duration.fiveDays => l10n.coBuyCreateDuration5Days,
    _Duration.oneWeek => l10n.coBuyCreateDuration1Week,
  };
}

class CoBuyCreateScreen extends ConsumerWidget {
  const CoBuyCreateScreen({super.key, this.editSessionId});

  /// When set, the form loads and edits this existing deal instead of
  /// creating a new one.
  final String? editSessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = editSessionId;
    if (editId == null) {
      return const _CoBuyCreateForm();
    }
    final sessionAsync = ref.watch(coBuyPoolByIdProvider(editId));
    return sessionAsync.when(
      data: (session) =>
          _CoBuyCreateForm(editSessionId: editId, initialSession: session),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).coBuyDealsLoadError),
        ),
      ),
    );
  }
}

class _CoBuyCreateForm extends ConsumerStatefulWidget {
  const _CoBuyCreateForm({this.editSessionId, this.initialSession});

  final String? editSessionId;
  final CoBuySession? initialSession;

  @override
  ConsumerState<_CoBuyCreateForm> createState() => _CoBuyCreateFormState();
}

class _CoBuyCreateFormState extends ConsumerState<_CoBuyCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _targetQtyController = TextEditingController();
  final _unitLabelController = TextEditingController();
  final _minOrderQtyController = TextEditingController();
  final _picker = ImagePicker();

  _Duration _duration = _Duration.threeDays;
  bool _autoRenew = false;
  bool _isSaving = false;
  final List<XFile?> _photos = List.filled(_kMaxPhotos, null);
  String? _existingCoverUrl;

  bool get _isEditing => widget.editSessionId != null;
  String get _editSessionId => widget.editSessionId!;

  @override
  void initState() {
    super.initState();
    final session = widget.initialSession;
    if (session == null) return;
    _productNameController.text = session.productName;
    _descriptionController.text = session.description;
    _priceController.text = session.price.toStringAsFixed(2);
    _originalPriceController.text = session.originalPrice.toStringAsFixed(2);
    _targetQtyController.text = '${session.targetQty}';
    _unitLabelController.text = session.unitLabel;
    _minOrderQtyController.text = '${session.minOrderQty}';
    _duration = _Duration.values.firstWhere(
      (d) => d.timeLeftText == session.timeLeft,
      orElse: () => _Duration.threeDays,
    );
    _autoRenew = session.autoRenew;
    // Existing photos are shown via [_existingCoverUrl]/network image, not
    // re-picked into [_photos] — only newly picked local files are uploaded
    // on save, and the backend keeps the existing photos when none are sent.
    _existingCoverUrl = session.imageUrl;
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _targetQtyController.dispose();
    _unitLabelController.dispose();
    _minOrderQtyController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(int index) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() => _photos[index] = picked);
    } catch (_) {
      // Ignore — the picker surfaces its own permission/UX errors.
    }
  }

  void _removePhoto(int index) {
    setState(() => _photos[index] = null);
  }

  List<File> get _pickedPhotoFiles => [
    for (final photo in _photos)
      if (photo != null) File(photo.path),
  ];

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final photos = _pickedPhotoFiles;
    final productName = _productNameController.text.trim();
    final description = _descriptionController.text.trim();
    final unitLabel = _unitLabelController.text.trim();
    final targetQty = int.parse(_targetQtyController.text.trim());
    final minOrderQty = int.parse(_minOrderQtyController.text.trim());
    final originalPrice = double.parse(_originalPriceController.text.trim());
    final price = double.parse(_priceController.text.trim());

    try {
      if (_isEditing) {
        await ref
            .read(coBuyProvider.notifier)
            .updateDeal(
              _editSessionId,
              productName: productName,
              targetQty: targetQty,
              unitLabel: unitLabel,
              perUnitLabel: 'per $unitLabel',
              minOrderQty: minOrderQty,
              timeLeft: _duration.timeLeftText,
              originalPrice: originalPrice,
              price: price,
              description: description,
              autoRenew: _autoRenew,
              photos: photos,
            );
        if (!mounted) return;
        ref.invalidate(coBuySellerPoolsProvider);
        ref.invalidate(coBuyPoolByIdProvider(_editSessionId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.coBuyCreateUpdatedSnackbar)),
        );
      } else {
        await ref
            .read(coBuyProvider.notifier)
            .create(
              productName: productName,
              targetQty: targetQty,
              unitLabel: unitLabel,
              perUnitLabel: 'per $unitLabel',
              minOrderQty: minOrderQty,
              timeLeft: _duration.timeLeftText,
              originalPrice: originalPrice,
              price: price,
              description: description,
              autoRenew: _autoRenew,
              photos: photos,
            );
        if (!mounted) return;
        ref.invalidate(coBuySellerPoolsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.coBuyCreateCreatedSnackbar)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.coBuyCreateSaveError)));
      return;
    }

    if (!mounted) return;
    context.pop();
  }

  String? _validatePositiveInt(
    String? value,
    String requiredMsg,
    String invalidMsg,
  ) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return requiredMsg;
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) return invalidMsg;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _Header(
            colorScheme: colorScheme,
            textTheme: textTheme,
            isEditing: _isEditing,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    16 + MediaQuery.of(context).padding.bottom,
                  ),
                  children: [
                    _SectionCard(
                      title: l10n.coBuyCreateProductInfoSectionTitle,
                      children: [
                        Text(
                          l10n.coBuyCreatePhotosLabel,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.warmBlack,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _CoverPhotoTile(
                          file: _photos[0],
                          existingImageUrl: _existingCoverUrl,
                          onTap: () => _pickPhoto(0),
                          onRemove: () => _removePhoto(0),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            for (var i = 1; i < _kMaxPhotos; i++) ...[
                              if (i > 1) const SizedBox(width: 12),
                              Expanded(
                                child: _AdditionalPhotoTile(
                                  file: _photos[i],
                                  onTap: () => _pickPhoto(i),
                                  onRemove: () => _removePhoto(i),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.coBuyCreatePhotosHelper,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.roseMist,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _AppTextField(
                          label: l10n.coBuyCreateProductNameLabel,
                          controller: _productNameController,
                          hintText: l10n.coBuyCreateProductNameHint,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? l10n.coBuyCreateProductNameRequired
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _AppTextField(
                          label: l10n.coBuyCreateDescriptionLabel,
                          controller: _descriptionController,
                          hintText: l10n.coBuyCreateDescriptionHint,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionCard(
                      title: l10n.coBuyCreatePricingSectionTitle,
                      children: [
                        _AppTextField(
                          label: l10n.coBuyCreateOriginalPriceLabel,
                          controller: _originalPriceController,
                          hintText: r'$0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) =>
                              _validatePrice(value, l10n, isOriginal: true),
                        ),
                        const SizedBox(height: 20),
                        _AppTextField(
                          label: l10n.coBuyCreatePriceLabel,
                          controller: _priceController,
                          hintText: r'$0.00',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) =>
                              _validatePrice(value, l10n, isOriginal: false),
                        ),
                        const SizedBox(height: 20),
                        _AppTextField(
                          label: l10n.coBuyCreateUnitLabelLabel,
                          controller: _unitLabelController,
                          hintText: l10n.coBuyCreateUnitLabelHint,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                              ? l10n.coBuyCreateUnitLabelRequired
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _AppTextField(
                          label: l10n.coBuyCreateMinOrderQtyLabel,
                          controller: _minOrderQtyController,
                          hintText: l10n.coBuyCreateMinOrderQtyHint,
                          keyboardType: TextInputType.number,
                          validator: (value) => _validatePositiveInt(
                            value,
                            l10n.coBuyCreateMinOrderQtyRequired,
                            l10n.coBuyCreateMinOrderQtyInvalid,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionCard(
                      title: l10n.coBuyCreateDealSettingsSectionTitle,
                      children: [
                        _AppTextField(
                          label: l10n.coBuyCreateTargetQtyLabel,
                          controller: _targetQtyController,
                          hintText: l10n.coBuyCreateTargetQtyHint,
                          keyboardType: TextInputType.number,
                          validator: (value) => _validatePositiveInt(
                            value,
                            l10n.coBuyCreateTargetQtyRequired,
                            l10n.coBuyCreateTargetQtyInvalid,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _DurationDropdown(
                          label: l10n.coBuyCreateDurationLabel,
                          value: _duration,
                          onChanged: (duration) =>
                              setState(() => _duration = duration),
                          l10n: l10n,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.coBuyCreateAutoRenewLabel,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warmBlack,
                                ),
                              ),
                            ),
                            Switch(
                              value: _autoRenew,
                              activeTrackColor: AppColors.brandCrimson,
                              activeThumbColor: Colors.white,
                              onChanged: (value) =>
                                  setState(() => _autoRenew = value),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _isSaving ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEditing
                                  ? l10n.commonSaveChanges
                                  : l10n.coBuyCreateButton,
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    if (_isEditing) ...[
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _isSaving ? null : () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          foregroundColor: AppColors.brandCrimson,
                          side: const BorderSide(color: AppColors.brandCrimson),
                        ),
                        child: Text(
                          l10n.commonCancel,
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validatePrice(
    String? value,
    AppLocalizations l10n, {
    required bool isOriginal,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return isOriginal
          ? l10n.coBuyCreateOriginalPriceRequired
          : l10n.coBuyCreatePriceRequired;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return isOriginal
          ? l10n.coBuyCreateOriginalPriceInvalid
          : l10n.coBuyCreatePriceInvalid;
    }
    if (isOriginal) {
      final price = double.tryParse(_priceController.text.trim());
      if (price != null && parsed <= price) {
        return l10n.coBuyCreateOriginalPriceInvalid;
      }
    }
    return null;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.colorScheme,
    required this.textTheme,
    required this.isEditing,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(color: colorScheme.primary),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            MediaQuery.of(context).padding.top + 16,
            24,
            20,
          ),
          child: SizedBox(
            height: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 2,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new,
                            color: colorScheme.onPrimary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.commonBack,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Text(
                  isEditing
                      ? l10n.coBuyCreateEditScreenTitle
                      : l10n.coBuyCreateScreenTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
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

/// A labeled, bordered white card grouping related fields — the same card
/// styling used across the co-buying detail screen (progress/order cards),
/// with the section title following the brand-crimson uppercase label style
/// already established by this form's duration/field labels.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.brandCrimson,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _CoverPhotoTile extends StatelessWidget {
  const _CoverPhotoTile({
    required this.file,
    required this.existingImageUrl,
    required this.onTap,
    required this.onRemove,
  });

  final XFile? file;
  final String? existingImageUrl;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    Widget? preview;
    if (file != null) {
      preview = Image.file(
        File(file!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (existingImageUrl != null) {
      preview = Image.network(
        existingImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_outlined, color: AppColors.brandCrimson),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: DottedBorderBox(
                color: AppColors.roseDivider,
                showBorder: preview == null,
                child: preview != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: preview,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.photo_camera_outlined,
                            size: 32,
                            color: AppColors.brandCrimson,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.coBuyCreatePhotoLabel,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.brandCrimson,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.coBuyCreatePhotoHint,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.roseMist,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (file != null || existingImageUrl != null)
            Positioned(
              right: 8,
              top: 8,
              child: RemovePhotoButton(onTap: onRemove),
            ),
        ],
      ),
    );
  }
}

class _AdditionalPhotoTile extends StatelessWidget {
  const _AdditionalPhotoTile({
    required this.file,
    required this.onTap,
    required this.onRemove,
  });

  final XFile? file;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: DottedBorderBox(
                borderRadius: 12,
                color: AppColors.roseDivider,
                showBorder: file == null,
                child: file != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(file!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : const Icon(
                        Icons.add,
                        color: AppColors.brandCrimson,
                        size: 22,
                      ),
              ),
            ),
          ),
          if (file != null)
            Positioned(
              right: 2,
              top: 2,
              child: RemovePhotoButton(onTap: onRemove, size: 18, iconSize: 12),
            ),
        ],
      ),
    );
  }
}

class _DurationDropdown extends StatelessWidget {
  const _DurationDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.l10n,
  });

  final String label;
  final _Duration value;
  final ValueChanged<_Duration> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.warmTaupe,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<_Duration>(
          initialValue: value,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.warmTaupe,
          ),
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.warmBlack,
          ),
          decoration: _fieldDecoration(),
          items: [
            for (final duration in _Duration.values)
              DropdownMenuItem(
                value: duration,
                child: Text(duration.label(l10n)),
              ),
          ],
          onChanged: (duration) {
            if (duration != null) onChanged(duration);
          },
        ),
      ],
    );
  }
}

InputDecoration _fieldDecoration({String? hintText}) {
  return InputDecoration(
    hintText: hintText,
    hintMaxLines: 4,
    hintStyle: const TextStyle(fontWeight: FontWeight.w400),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.roseDivider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.roseDivider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.brandCrimson, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.warmTaupe,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.warmBlack,
          ),
          decoration: _fieldDecoration(hintText: hintText),
          validator: validator,
        ),
      ],
    );
  }
}
