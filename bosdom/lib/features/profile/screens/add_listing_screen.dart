import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/dotted_border_box.dart';
import '../../../shared/widgets/variant_options_editor.dart';
import '../../marketplace/models/category.dart';
import '../services/listing_service.dart';

const _kMaxPhotos = 5;

class _CategorySpecCopy {
  const _CategorySpecCopy({
    required this.weightLabel,
    required this.weightHint,
    required this.originHint,
    required this.gradeLabel,
    required this.gradeHint,
    required this.packagingHint,
  });

  final String weightLabel;
  final String weightHint;
  final String originHint;
  final String gradeLabel;
  final String gradeHint;
  final String packagingHint;
}

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _moqController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _samplePriceController = TextEditingController();
  final _weightController = TextEditingController();
  final _originController = TextEditingController();
  final _gradeController = TextEditingController();
  final _packagingController = TextEditingController();
  final _picker = ImagePicker();

  String? _category;
  final List<XFile?> _photos = List.filled(_kMaxPhotos, null);
  bool _sampleTestingEnabled = false;
  bool _isSaving = false;
  bool _showCoverPhotoError = false;

  final _variants = VariantOptionsController();

  _CategorySpecCopy _specCopyFor(AppLocalizations l10n) {
    switch (_category) {
      case 'Electronics':
        return _CategorySpecCopy(
          weightLabel: l10n.addListingWeightLabelElectronics,
          weightHint: l10n.addListingWeightHintElectronics,
          originHint: l10n.addListingOriginHintElectronics,
          gradeLabel: l10n.addListingGradeLabel,
          gradeHint: l10n.addListingGradeHintElectronics,
          packagingHint: l10n.addListingPackagingHintElectronics,
        );
      case 'Clothing':
        return _CategorySpecCopy(
          weightLabel: l10n.addListingWeightLabelClothing,
          weightHint: l10n.addListingWeightHintClothing,
          originHint: l10n.addListingOriginHintClothing,
          gradeLabel: l10n.addListingGradeLabelMaterial,
          gradeHint: l10n.addListingGradeHintClothing,
          packagingHint: l10n.addListingPackagingHintClothing,
        );
      case 'Beauty':
        return _CategorySpecCopy(
          weightLabel: l10n.addListingWeightLabelBeauty,
          weightHint: l10n.addListingWeightHintBeauty,
          originHint: l10n.addListingOriginHintBeauty,
          gradeLabel: l10n.addListingGradeLabel,
          gradeHint: l10n.addListingGradeHintBeauty,
          packagingHint: l10n.addListingPackagingHintBeauty,
        );
      case 'Home':
        return _CategorySpecCopy(
          weightLabel: l10n.addListingWeightLabel,
          weightHint: l10n.addListingWeightHintHome,
          originHint: l10n.addListingOriginHintHome,
          gradeLabel: l10n.addListingGradeLabelMaterial,
          gradeHint: l10n.addListingGradeHintHome,
          packagingHint: l10n.addListingPackagingHintHome,
        );
      case 'Food & Bev':
      default:
        return _CategorySpecCopy(
          weightLabel: l10n.addListingWeightLabel,
          weightHint: l10n.addListingWeightHint,
          originHint: l10n.addListingOriginHint,
          gradeLabel: l10n.addListingGradeLabel,
          gradeHint: l10n.addListingGradeHint,
          packagingHint: l10n.addListingPackagingHint,
        );
    }
  }

  void _onCategoryChanged(String? value) {
    setState(() => _category = value);
    _variants.setCategory(value);
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _moqController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    _samplePriceController.dispose();
    _weightController.dispose();
    _originController.dispose();
    _gradeController.dispose();
    _packagingController.dispose();
    _variants.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(int index) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() {
      _photos[index] = picked;
      if (index == 0) _showCoverPhotoError = false;
    });
  }

  void _removePhoto(int index) {
    setState(() => _photos[index] = null);
  }

  /// Pulls the backend's `detail` message out of a
  /// `Failed to create listing: <response body>` exception, so the user
  /// sees the real reason (e.g. pending seller approval) instead of a
  /// generic error.
  String? _serverErrorDetail(Object error) {
    final message = error.toString();
    const prefix = 'Exception: Failed to create listing: ';
    if (!message.startsWith(prefix)) return null;
    final body = message.substring(prefix.length);
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['detail'] is String) {
        return decoded['detail'] as String;
      }
    } catch (_) {
      // Response body wasn't JSON; fall back to the generic message.
    }
    return null;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    final formValid = _formKey.currentState?.validate() ?? false;
    final hasCoverPhoto = _photos[0] != null;
    setState(() => _showCoverPhotoError = !hasCoverPhoto);
    if (!formValid || !hasCoverPhoto) return;

    final price = double.tryParse(_priceController.text.trim());
    final moqQty = int.tryParse(_moqController.text.trim());
    final stockQty = int.tryParse(_stockController.text.trim());
    final samplePrice = _sampleTestingEnabled
        ? double.tryParse(_samplePriceController.text.trim())
        : null;
    if (price == null ||
        moqQty == null ||
        stockQty == null ||
        (_sampleTestingEnabled && samplePrice == null)) {
      // The per-field validators should already catch this, but fall back
      // to a friendly message instead of letting a raw parse exception
      // reach the snackbar (e.g. a field built offscreen never validated).
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addListingCreateErrorSnackbar)),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ListingService.create(
        productName: _productNameController.text.trim(),
        category: _category!,
        price: price,
        moqQty: moqQty,
        stockQty: stockQty,
        description: _descriptionController.text.trim(),
        sampleTestingEnabled: _sampleTestingEnabled,
        samplePrice: samplePrice,
        sizes: _variants.sizes,
        colors: [
          for (final color in _variants.colors)
            ListingColorOption(name: color.name, hex: color.hex),
        ],
        weight: _weightController.text.trim(),
        origin: _originController.text.trim(),
        grade: _gradeController.text.trim(),
        packaging: _packagingController.text.trim(),
        photos: [
          for (final photo in _photos)
            if (photo != null) File(photo.path),
        ],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addListingCreatedSnackbar)));
      context.pop();
    } catch (e) {
      debugPrint('Add listing failed: $e');
      if (!mounted) return;
      final message =
          _serverErrorDetail(e) ?? '${l10n.addListingCreateErrorSnackbar} ($e)';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final specCopy = _specCopyFor(l10n);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    24 + MediaQuery.of(context).padding.bottom,
                  ),
                  children: [
                    _AppTextField(
                      label: l10n.addListingProductNameLabel,
                      controller: _productNameController,
                      icon: Icons.inventory_2_outlined,
                      hintText: l10n.addListingProductNameHint,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? l10n.addListingProductNameRequired
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _CategoryDropdown(
                      value: _category,
                      hintText: l10n.addListingCategoryHint,
                      label: l10n.addListingCategoryLabel,
                      errorText: l10n.addListingCategoryRequired,
                      onChanged: _onCategoryChanged,
                    ),
                    VariantOptionsEditor(controller: _variants),
                    const SizedBox(height: 24),
                    _AppTextField(
                      label: l10n.addListingPriceLabel,
                      controller: _priceController,
                      icon: Icons.attach_money,
                      hintText: r'$0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) =>
                          _validatePositiveDouble(value, l10n),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _AppTextField(
                            label: l10n.addListingMoqLabel,
                            controller: _moqController,
                            icon: Icons.numbers,
                            hintText: l10n.addListingMoqHint,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return l10n.addListingMoqRequired;
                              }
                              final parsed = int.tryParse(trimmed);
                              if (parsed == null || parsed <= 0) {
                                return l10n.addListingMoqInvalid;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AppTextField(
                            label: l10n.addListingStockLabel,
                            controller: _stockController,
                            icon: Icons.warehouse_outlined,
                            hintText: l10n.addListingStockHint,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return l10n.addListingStockRequired;
                              }
                              final parsed = int.tryParse(trimmed);
                              if (parsed == null || parsed < 0) {
                                return l10n.addListingStockInvalid;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.addListingSpecsLabel,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warmBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.addListingSpecsHelper,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.roseMist,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _AppTextField(
                            label: specCopy.weightLabel,
                            controller: _weightController,
                            icon: Icons.scale_outlined,
                            hintText: specCopy.weightHint,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return l10n.addListingWeightRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AppTextField(
                            label: l10n.addListingOriginLabel,
                            controller: _originController,
                            icon: Icons.public,
                            hintText: specCopy.originHint,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return l10n.addListingOriginRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _AppTextField(
                            label: specCopy.gradeLabel,
                            controller: _gradeController,
                            icon: Icons.workspace_premium_outlined,
                            hintText: specCopy.gradeHint,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return l10n.addListingGradeRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AppTextField(
                            label: l10n.addListingPackagingLabel,
                            controller: _packagingController,
                            icon: Icons.archive_outlined,
                            hintText: specCopy.packagingHint,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if ((value ?? '').trim().isEmpty) {
                                return l10n.addListingPackagingRequired;
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.addListingPhotosLabel,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warmBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _CoverPhotoTile(
                      file: _photos[0],
                      hasError: _showCoverPhotoError,
                      onTap: () => _pickPhoto(0),
                      onRemove: () => _removePhoto(0),
                    ),
                    if (_showCoverPhotoError) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.addListingCoverPhotoRequired,
                        style: textTheme.bodySmall?.copyWith(color: Colors.red),
                      ),
                    ],
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
                      l10n.addListingPhotosHelper,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.roseMist,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _AppTextField(
                      label: l10n.addListingDescriptionLabel,
                      controller: _descriptionController,
                      hintText: l10n.addListingDescriptionHint,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.addListingSampleTestingLabel,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warmBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SampleTestingToggle(
                      value: _sampleTestingEnabled,
                      title: l10n.addListingSampleTestingToggleTitle,
                      subtitle: l10n.addListingSampleTestingToggleSubtitle,
                      onChanged: (value) =>
                          setState(() => _sampleTestingEnabled = value),
                    ),
                    if (_sampleTestingEnabled) ...[
                      const SizedBox(height: 24),
                      _AppTextField(
                        label: l10n.addListingSamplePriceLabel,
                        controller: _samplePriceController,
                        icon: Icons.attach_money,
                        hintText: r'$0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) =>
                            _validatePositiveDouble(value, l10n, sample: true),
                      ),
                    ],
                    const SizedBox(height: 32),
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
                              l10n.addListingCreateButton,
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validatePositiveDouble(
    String? value,
    AppLocalizations l10n, {
    bool sample = false,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return sample
          ? l10n.addListingSamplePriceRequired
          : l10n.addListingPriceRequired;
    }
    final parsed = double.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return sample
          ? l10n.addListingSamplePriceInvalid
          : l10n.addListingPriceInvalid;
    }
    // A sample is one unit bought to test quality, sold at full price —
    // never below the wholesale unit price (the backend enforces it too).
    final wholesale = double.tryParse(_priceController.text.trim());
    if (sample && wholesale != null && parsed < wholesale) {
      return l10n.addListingSamplePriceBelowWholesale;
    }
    return null;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 10,
          24,
          14,
        ),
        child: SizedBox(
          height: 68,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.goNamed('sellerDashboard'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Icon(
                      Icons.arrow_back,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Text(
                l10n.addListingScreenTitle,
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
    );
  }
}

class _CoverPhotoTile extends StatelessWidget {
  const _CoverPhotoTile({
    required this.file,
    required this.hasError,
    required this.onTap,
    required this.onRemove,
  });

  final XFile? file;
  final bool hasError;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: DottedBorderBox(
                color: hasError ? Colors.red : AppColors.roseDivider,
                showBorder: file == null,
                child: file != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(file!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
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
                            l10n.addListingCoverPhotoCta,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.brandCrimson,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.addListingPhotosFormatHint,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.roseMist,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (file != null)
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

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.value,
    required this.label,
    required this.hintText,
    required this.errorText,
    required this.onChanged,
  });

  final String? value;
  final String label;
  final String hintText;
  final String errorText;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.brandCrimson,
      ),
      decoration: _fieldDecoration(
        label: label,
        icon: Icons.category_outlined,
        hintText: hintText,
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.warmBlack,
      ),
      items: [
        for (final category in kCategories)
          DropdownMenuItem(
            value: category.label,
            child: Text(
              categoryDisplayName(AppLocalizations.of(context), category.label),
            ),
          ),
      ],
      validator: (value) => value == null ? errorText : null,
      onChanged: onChanged,
    );
  }
}

class _SampleTestingToggle extends StatelessWidget {
  const _SampleTestingToggle({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final bool value;
  final String title;
  final String subtitle;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.roseDivider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warmBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.roseMist,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.brandCrimson,
          ),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required String label,
  IconData? icon,
  String? hintText,
  int maxLines = 1,
}) {
  return InputDecoration(
    labelText: label.toUpperCase(),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    hintText: hintText,
    hintMaxLines: maxLines,
    hintStyle: const TextStyle(fontWeight: FontWeight.w400),
    alignLabelWithHint: maxLines > 1,
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    prefixIcon: icon == null
        ? null
        : Icon(icon, color: AppColors.brandCrimson, size: 20),
    prefixIconConstraints: icon == null
        ? null
        : const BoxConstraints(minWidth: 44, minHeight: 24),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: const TextStyle(
      color: AppColors.brandCrimson,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.6,
      fontSize: 12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.roseDivider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.roseDivider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.brandCrimson, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );
}

class _AppTextField extends StatelessWidget {
  const _AppTextField({
    required this.label,
    required this.controller,
    this.icon,
    required this.hintText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final String hintText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      textAlignVertical: maxLines == 1
          ? TextAlignVertical.center
          : TextAlignVertical.top,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.warmBlack,
      ),
      decoration: _fieldDecoration(
        label: label,
        icon: icon,
        hintText: hintText,
        maxLines: maxLines,
      ),
      validator: validator,
    );
  }
}
