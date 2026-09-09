import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/models/merchant_role.dart';
import '../models/user_profile.dart';
import '../providers/profile_provider.dart';

final _kEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _picker = ImagePicker();

  MerchantRole _role = MerchantRole.retailer;
  XFile? _avatarFile;
  bool _initialized = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _applyProfile(UserProfile profile) {
    _nameController.text = profile.name;
    _phoneController.text = profile.phone;
    _emailController.text = profile.email;
    _role = MerchantRole.values.firstWhere(
      (role) => role.name == profile.role,
      orElse: () => MerchantRole.retailer,
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() {
        _avatarFile = picked;
        _isUploadingAvatar = true;
      });
      try {
        await ref
            .read(profileProvider.notifier)
            .uploadAvatar(File(picked.path));
      } catch (_) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileEditProfileSaveErrorSnackbar)),
        );
      } finally {
        if (mounted) setState(() => _isUploadingAvatar = false);
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
          .read(profileProvider.notifier)
          .save(
            UserProfile(
              name: _nameController.text.trim(),
              phone: _phoneController.text.trim(),
              role: _role.name,
              email: _emailController.text.trim(),
              avatarUrl: ref.read(profileProvider).value?.avatarUrl ?? '',
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileEditProfileSavedSnackbar)),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileEditProfileSaveErrorSnackbar)),
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

    ref.listen<AsyncValue<UserProfile>>(profileProvider, (previous, next) {
      final profile = next.value;
      if (profile != null && !_initialized) {
        _initialized = true;
        _applyProfile(profile);
      }
    });

    final profileState = ref.watch(profileProvider);
    if (!_initialized) {
      final profile = profileState.value;
      if (profile != null) {
        _initialized = true;
        _applyProfile(profile);
      }
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _EditProfileHeader(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              child: profileState.isLoading && !_initialized
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        children: [
                          Center(
                            child: _AvatarPicker(
                              file: _avatarFile,
                              networkAvatarUrl: profileState.value?.avatarUrl,
                              isUploading: _isUploadingAvatar,
                              onTap: _pickAvatar,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _ReadOnlyField(
                            label: l10n.profileEditProfileRoleLabel,
                            icon: Icons.person_outline,
                            value: _role.title,
                          ),
                          const SizedBox(height: 20),
                          _AppTextField(
                            label: l10n.profileEditProfileNameLabel,
                            controller: _nameController,
                            icon: Icons.edit_outlined,
                            hintText: l10n.profileEditProfileNameHint,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? l10n.profileEditProfileNameRequired
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _AppTextField(
                            label: l10n.profileEditProfilePhoneLabel,
                            controller: _phoneController,
                            icon: Icons.phone_outlined,
                            hintText: l10n.profileEditProfilePhoneHint,
                            keyboardType: TextInputType.phone,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? l10n.profileEditProfilePhoneRequired
                                : null,
                          ),
                          const SizedBox(height: 20),
                          _AppTextField(
                            label: l10n.profileEditProfileEmailLabel,
                            controller: _emailController,
                            icon: Icons.mail_outline,
                            hintText: l10n.profileEditProfileEmailHint,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final trimmed = value?.trim() ?? '';
                              if (trimmed.isEmpty) {
                                return l10n.profileEditProfileEmailRequired;
                              }
                              if (!_kEmailPattern.hasMatch(trimmed)) {
                                return l10n.profileEditProfileEmailInvalid;
                              }
                              return null;
                            },
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
                                    l10n.profileEditProfileSaveButton,
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

class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader({
    required this.colorScheme,
    required this.textTheme,
  });

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
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.goNamed('profile'),
                  borderRadius: BorderRadius.circular(8),
                  child: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
              Text(
                l10n.profileEditProfileLabel,
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

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.file,
    required this.networkAvatarUrl,
    required this.isUploading,
    required this.onTap,
  });

  static const double _size = 136;

  final XFile? file;
  final String? networkAvatarUrl;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ImageProvider? backgroundImage;
    final resolvedAvatarUrl = ApiConfig.resolveAvatarUrl(networkAvatarUrl);
    if (file != null) {
      backgroundImage = FileImage(File(file!.path));
    } else if (resolvedAvatarUrl != null) {
      backgroundImage = NetworkImage(resolvedAvatarUrl);
    }

    return Semantics(
      button: true,
      label: l10n.profileEditProfileChangePhoto,
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
                backgroundColor: AppColors.blushSurface,
                backgroundImage: backgroundImage,
                child: backgroundImage == null
                    ? const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.roseMist,
                      )
                    : null,
              ),
              if (isUploading)
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
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
                    color: AppColors.brandCrimson,
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
  required IconData icon,
  String? hintText,
}) {
  return InputDecoration(
    labelText: label.toUpperCase(),
    floatingLabelBehavior: FloatingLabelBehavior.always,
    hintText: hintText,
    hintStyle: const TextStyle(fontWeight: FontWeight.w400),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    prefixIcon: Icon(icon, color: AppColors.brandCrimson, size: 20),
    prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 24),
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
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.warmBlack,
      ),
      decoration: _fieldDecoration(
        label: label,
        icon: icon,
        hintText: hintText,
      ),
      validator: validator,
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _fieldDecoration(label: label, icon: icon),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.warmBlack,
        ),
      ),
    );
  }
}
