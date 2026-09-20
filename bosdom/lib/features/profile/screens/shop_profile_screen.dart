import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/shop_profile.dart';
import '../providers/shop_profile_provider.dart';

final _kEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class ShopProfileScreen extends ConsumerStatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  ConsumerState<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends ConsumerState<ShopProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _yearEstablishedController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _picker = ImagePicker();

  XFile? _logoFile;
  bool _initialized = false;
  bool _isSaving = false;
  bool _isUploadingLogo = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _businessTypeController.dispose();
    _yearEstablishedController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _applyShop(ShopProfile shop) {
    _shopNameController.text = shop.shopName;
    _businessTypeController.text = shop.businessType;
    _yearEstablishedController.text = shop.yearEstablished;
    _locationController.text = shop.location;
    _phoneController.text = shop.phone;
    _emailController.text = shop.email;
    _descriptionController.text = shop.description;
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
      setState(() {
        _logoFile = picked;
        _isUploadingLogo = true;
      });
      try {
        await ref
            .read(shopProfileProvider.notifier)
            .uploadLogo(File(picked.path));
      } catch (_) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.shopProfileSaveErrorSnackbar)),
        );
      } finally {
        if (mounted) setState(() => _isUploadingLogo = false);
      }
    } catch (_) {
      // Ignore — the picker surfaces its own permission/UX errors.
    }
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await ref
          .read(shopProfileProvider.notifier)
          .save(
            ShopProfile(
              shopName: _shopNameController.text.trim(),
              businessType: _businessTypeController.text.trim(),
              yearEstablished: _yearEstablishedController.text.trim(),
              location: _locationController.text.trim(),
              phone: _phoneController.text.trim(),
              email: _emailController.text.trim(),
              description: _descriptionController.text.trim(),
              // This screen doesn't expose store type / online store URL
              // fields — carry the values set during onboarding forward
              // instead of silently wiping them on every save.
              storeType: ref.read(shopProfileProvider).value?.storeType ?? '',
              storeUrl: ref.read(shopProfileProvider).value?.storeUrl ?? '',
              logoUrl: ref.read(shopProfileProvider).value?.logoUrl ?? '',
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.shopProfileSavedSnackbar)));
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.shopProfileSaveErrorSnackbar)),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    ref.listen<AsyncValue<ShopProfile>>(shopProfileProvider, (previous, next) {
      final shop = next.value;
      if (shop != null && !_initialized) {
        _initialized = true;
        _applyShop(shop);
      }
    });

    final shopState = ref.watch(shopProfileProvider);
    if (!_initialized) {
      final shop = shopState.value;
      if (shop != null) {
        _initialized = true;
        _applyShop(shop);
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: shopState.isLoading && !_initialized
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        children: [
                          Center(
                            child: Column(
                              children: [
                                _LogoPicker(
                                  file: _logoFile,
                                  networkLogoUrl: shopState.value?.logoUrl,
                                  isUploading: _isUploadingLogo,
                                  colorScheme: colorScheme,
                                  onTap: _changeLogo,
                                ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: _changeLogo,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      l10n.shopProfileChangeLogo,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _AppTextField(
                            label: l10n.shopProfileShopNameLabel,
                            controller: _shopNameController,
                            icon: Icons.storefront_outlined,
                            hintText: l10n.shopProfileShopNameHint,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? l10n.shopProfileShopNameRequired
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _AppTextField(
                            label: l10n.shopProfileBusinessTypeLabel,
                            controller: _businessTypeController,
                            icon: Icons.category_outlined,
                            hintText: l10n.shopProfileBusinessTypeHint,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? l10n.shopProfileBusinessTypeRequired
                                : null,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _AppTextField(
                                  label: l10n.shopProfileYearEstablishedLabel,
                                  controller: _yearEstablishedController,
                                  icon: Icons.calendar_today_outlined,
                                  hintText: l10n.shopProfileYearEstablishedHint,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AppTextField(
                                  label: l10n.shopProfileLocationLabel,
                                  controller: _locationController,
                                  icon: Icons.location_on_outlined,
                                  hintText: l10n.shopProfileLocationHint,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? l10n.shopProfileLocationRequired
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _AppTextField(
                            label: l10n.shopProfilePhoneLabel,
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            hintText: l10n.shopProfilePhoneHint,
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? l10n.shopProfilePhoneRequired
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _AppTextField(
                            label: l10n.shopProfileEmailLabel,
                            controller: _emailController,
                            icon: Icons.mail_outline,
                            hintText: l10n.shopProfileEmailHint,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return l10n.shopProfileEmailRequired;
                              }
                              if (!_kEmailPattern.hasMatch(trimmed)) {
                                return l10n.shopProfileEmailInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _AppTextField(
                            label: l10n.shopProfileDescriptionLabel,
                            controller: _descriptionController,
                            hintText: l10n.shopProfileDescriptionHint,
                            maxLines: 4,
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
                                    l10n.shopProfileSaveButton,
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
                      : context.goNamed('profile'),
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
                l10n.shopProfileScreenTitle,
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

class _LogoPicker extends StatelessWidget {
  const _LogoPicker({
    required this.file,
    required this.networkLogoUrl,
    required this.isUploading,
    required this.colorScheme,
    required this.onTap,
  });

  static const double _size = 136;

  final XFile? file;
  final String? networkLogoUrl;
  final bool isUploading;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ImageProvider? backgroundImage;
    final resolvedLogoUrl = ApiConfig.resolveAvatarUrl(networkLogoUrl);
    if (file != null) {
      backgroundImage = FileImage(File(file!.path));
    } else if (resolvedLogoUrl != null) {
      backgroundImage = NetworkImage(resolvedLogoUrl);
    }

    return Semantics(
      button: true,
      label: l10n.shopProfileChangeLogo,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: _size / 2,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: backgroundImage,
                child: backgroundImage == null
                    ? Icon(
                        Icons.storefront_rounded,
                        size: 56,
                        color: colorScheme.primary,
                      )
                    : null,
              ),
              if (isUploading)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration({
  required String label,
  IconData? icon,
  String? hintText,
  bool alignLabelWithHint = false,
}) {
  return InputDecoration(
    labelText: label.toUpperCase(),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    hintText: hintText,
    hintStyle: const TextStyle(fontWeight: FontWeight.w400),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    alignLabelWithHint: alignLabelWithHint,
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
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.warmBlack,
      ),
      decoration: _fieldDecoration(
        label: label,
        icon: icon,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
    );
  }
}
