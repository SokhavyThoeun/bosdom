import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/cambodia_locations.dart';
import '../../profile/models/shop_profile.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/providers/shop_profile_provider.dart';
import '../../profile/services/profile_service.dart';
import '../../profile/widgets/seller_approval_gate.dart';
import '../models/merchant_role.dart';
import '../services/signup_draft.dart';

const _kStoreTypes = [
  'Physical Store',
  'Online Store',
  'Both Physical & Online',
];

const _kMaxStorePhotos = 4;

class BusinessInfoScreen extends ConsumerStatefulWidget {
  const BusinessInfoScreen({
    required this.role,
    this.standalone = false,
    super.key,
  });

  final MerchantRole role;

  /// True when reached from the profile's "Become a Seller" card rather
  /// than the account signup wizard — shortens the step counter to this
  /// flow's own 2 steps, activates the seller role on the existing
  /// profile instead of mock-creating a new account, and returns to the
  /// profile screen instead of the marketplace.
  final bool standalone;

  @override
  ConsumerState<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends ConsumerState<BusinessInfoScreen> {
  final _shopNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _yearEstablishedController = TextEditingController();
  final _storeUrlController = TextEditingController();
  final _streetController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();
  String? _storeType;
  String? _province;
  String? _district;
  String? _sangkat;
  final List<XFile> _storePhotos = [];
  bool _agreed = false;
  bool _isSubmitting = false;
  XFile? _logoFile;

  Map<String, List<String>>? get _districtsForProvince =>
      kCambodiaDistricts[_province];

  @override
  void dispose() {
    _shopNameController.dispose();
    _businessTypeController.dispose();
    _yearEstablishedController.dispose();
    _storeUrlController.dispose();
    _streetController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _changeLogo() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() => _logoFile = picked);
    } catch (_) {
      // Ignore — the picker surfaces its own permission/UX errors.
    }
  }

  void _goBack() {
    if (widget.standalone) {
      context.pop();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('personalDetails', extra: widget.role);
    }
  }

  Future<void> _addStorePhoto() async {
    final remaining = _kMaxStorePhotos - _storePhotos.length;
    if (remaining <= 0) return;
    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked.isEmpty || !mounted) return;
      setState(() => _storePhotos.addAll(picked.take(remaining)));
    } catch (_) {
      // Ignore — the picker surfaces its own permission/UX errors.
    }
  }

  void _removeStorePhoto(int index) {
    setState(() => _storePhotos.removeAt(index));
  }

  void _onProvinceChanged(String? value) {
    setState(() {
      _province = value;
      _district = null;
      _sangkat = null;
    });
  }

  ShopProfile _buildShopProfile() {
    final districtSangkat = [
      if (_sangkat != null) 'Sangkat $_sangkat',
      if (_district != null) 'Khan $_district',
    ].join(', ');
    final location = [
      _streetController.text.trim(),
      districtSangkat,
      _province ?? '',
    ].where((part) => part.isNotEmpty).join(', ');

    return ShopProfile(
      shopName: _shopNameController.text.trim(),
      businessType: _businessTypeController.text.trim(),
      storeType: _storeType ?? '',
      yearEstablished: _yearEstablishedController.text.trim(),
      location: location,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      description: _descriptionController.text.trim(),
      storeUrl: _storeUrlController.text.trim(),
    );
  }

  /// Saves the shop's text fields, then the logo and store photos.
  /// Returns false (without throwing) if any step fails, so callers can
  /// still complete onboarding but let the user know images need a retry.
  Future<bool> _saveShopProfile() async {
    try {
      await ref.read(shopProfileProvider.notifier).save(_buildShopProfile());
      if (_logoFile != null) {
        await ref
            .read(shopProfileProvider.notifier)
            .uploadLogo(File(_logoFile!.path));
      }
      if (_storePhotos.isNotEmpty) {
        await ref
            .read(shopProfileProvider.notifier)
            .uploadStorePhotos(_storePhotos.map((f) => File(f.path)).toList());
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _createAccount() async {
    if (!_agreed || _isSubmitting) return;

    if (widget.standalone) {
      final profile = ref.read(profileProvider).value;
      if (profile != null) {
        try {
          await ref
              .read(profileProvider.notifier)
              .save(profile.copyWith(role: MerchantRole.supplier.name));
        } catch (_) {
          // profileProvider.save already reverts local state on failure;
          // still surface the success message optimistically below since
          // this form itself is mock (no real KYC/backend wiring yet).
        }
      }
      final shopSaved = await _saveShopProfile();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            shopSaved
                ? l10n.profileSellerActivatedSnackbar
                : l10n.profileShopPhotosUploadFailed,
          ),
        ),
      );
      await showSellerAwaitingApprovalDialog(context);
      if (!mounted) return;
      context.goNamed('profile');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // The account and profile already exist (created back at the
      // personal-details step) — this is the wizard's last step, so it's
      // what actually marks the account as onboarded rather than abandoned
      // mid-signup. See ProfileService.completeOnboarding.
      await ProfileService.completeOnboarding();
      final shopSaved = await _saveShopProfile();
      SignupDraft.clear();
      if (mounted && !shopSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).profileShopPhotosUploadFailed,
            ),
          ),
        );
      }
      if (mounted) {
        if (widget.role == MerchantRole.supplier) {
          await showSellerAwaitingApprovalDialog(context);
        }
        if (mounted) context.goNamed('marketplace');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          _Header(
            colorScheme: colorScheme,
            textTheme: textTheme,
            currentStep: widget.standalone ? 2 : widget.role.totalSteps,
            totalSteps: widget.standalone ? 2 : widget.role.totalSteps,
            onBack: _goBack,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: _LogoPicker(
                        file: _logoFile,
                        colorScheme: colorScheme,
                        onTap: _changeLogo,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _FormField(
                      label: 'SHOP / BUSINESS NAME',
                      controller: _shopNameController,
                      hintText: 'e.g. Angkor Wholesale Co.',
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'BUSINESS TYPE',
                      controller: _businessTypeController,
                      hintText: 'e.g. Manufacturer & Distributor',
                    ),
                    const SizedBox(height: 20),
                    _DropdownField(
                      label: 'TYPE OF STORE',
                      hintText: 'Select a type',
                      value: _storeType,
                      items: _kStoreTypes,
                      onChanged: (value) => setState(() => _storeType = value),
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'YEAR ESTABLISHED',
                      controller: _yearEstablishedController,
                      hintText: 'e.g. 2018',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    _StorePhotosField(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      photos: _storePhotos,
                      onAdd: _addStorePhoto,
                      onRemove: _removeStorePhoto,
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'ONLINE STORE URL (OPTIONAL)',
                      controller: _storeUrlController,
                      hintText: 'e.g. facebook.com/yourshop',
                    ),
                    const SizedBox(height: 20),
                    _DropdownField(
                      label: 'PROVINCE / CITY',
                      hintText: 'Select province...',
                      value: _province,
                      items: kCambodiaProvinces,
                      onChanged: _onProvinceChanged,
                    ),
                    const SizedBox(height: 20),
                    _DropdownField(
                      label: 'DISTRICT (KHAN)',
                      hintText: _province == null
                          ? 'Select province first'
                          : 'Select district...',
                      value: _district,
                      items: _districtsForProvince?.keys.toList() ?? const [],
                      onChanged: (value) => setState(() {
                        _district = value;
                        _sangkat = null;
                      }),
                    ),
                    const SizedBox(height: 20),
                    _DropdownField(
                      label: 'SANGKAT',
                      hintText: _district == null
                          ? 'Select district first'
                          : 'Select sangkat...',
                      value: _sangkat,
                      items: _district == null
                          ? const []
                          : _districtsForProvince?[_district] ?? const [],
                      onChanged: (value) => setState(() => _sangkat = value),
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'STREET ADDRESS',
                      controller: _streetController,
                      hintText: 'e.g. Street 271, Phnom Penh',
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'PHONE NUMBER',
                      controller: _phoneController,
                      hintText: 'Enter your business phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'EMAIL ADDRESS',
                      controller: _emailController,
                      hintText: 'Enter your business email address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'BUSINESS DESCRIPTION',
                      controller: _descriptionController,
                      hintText: 'Tell buyers about your business',
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),
                    _AgreementRow(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      agreed: _agreed,
                      onChanged: (value) => setState(() => _agreed = value),
                    ),
                    const SizedBox(height: 20),
                    _SellerBadgeNote(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _agreed && !_isSubmitting
                          ? _createAccount
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          widget.standalone
                              ? 'Activate my Seller Account'
                              : 'Create my Account',
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
}

class _Header extends StatelessWidget {
  const _Header({
    required this.colorScheme,
    required this.textTheme,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 10,
          24,
          18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left, color: colorScheme.onPrimary),
                    Text(
                      'Back',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Business Info',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Step $currentStep of $totalSteps',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(totalSteps, (index) {
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(
                      right: index == totalSteps - 1 ? 0 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: index < currentStep
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        alignLabelWithHint: maxLines > 1,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _LogoPicker extends StatelessWidget {
  const _LogoPicker({
    required this.file,
    required this.colorScheme,
    required this.onTap,
  });

  static const double _size = 120;

  final XFile? file;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: _size / 2,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: file == null
                      ? null
                      : FileImage(File(file!.path)),
                  child: file == null
                      ? Icon(
                          Icons.storefront_rounded,
                          size: 48,
                          color: colorScheme.primary,
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Change Store Logo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String hintText;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DropdownButtonFormField<String>(
      initialValue: items.contains(value) ? value : null,
      icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: items.isEmpty ? null : onChanged,
    );
  }
}

class _StorePhotosField extends StatelessWidget {
  const _StorePhotosField({
    required this.colorScheme,
    required this.textTheme,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final List<XFile> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final isFull = photos.length >= _kMaxStorePhotos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STORE PHOTOS',
          style: textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isFull ? null : onAdd,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: isFull
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isFull
                      ? 'Maximum $_kMaxStorePhotos photos added'
                      : 'Tap to upload store photos',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '(Physical store or online store screenshots)',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var index = 0; index < _kMaxStorePhotos; index++) ...[
              if (index != 0) const SizedBox(width: 12),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: InkWell(
                    onTap: index < photos.length ? () => onRemove(index) : null,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.4),
                        ),
                      ),
                      child: index < photos.length
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(
                                  File(photos[index].path),
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Icon(
                              Icons.image_outlined,
                              color: colorScheme.onSurfaceVariant,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({
    required this.colorScheme,
    required this.textTheme,
    required this.agreed,
    required this.onChanged,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool agreed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!agreed),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: agreed ? colorScheme.primary : Colors.transparent,
                  border: Border.all(color: colorScheme.primary, width: 1.5),
                ),
                child: agreed
                    ? Icon(Icons.check, size: 14, color: colorScheme.onPrimary)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  children: [
                    const TextSpan(text: "I agree to BosDom's "),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' and confirm I am a registered business merchant '
                          'in Cambodia.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerBadgeNote extends StatelessWidget {
  const _SellerBadgeNote({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(text: 'Your '),
                  TextSpan(
                    text: 'Seller badge',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(
                    text:
                        ' activates immediately. You can start listing '
                        'products right away!',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
