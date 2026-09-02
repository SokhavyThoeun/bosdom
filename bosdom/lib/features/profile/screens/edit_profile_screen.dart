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

  Future<void> _selectRole() async {
    final selected = await showModalBottomSheet<MerchantRole>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _RolePickerSheet(selected: _role),
    );
    if (selected != null) setState(() => _role = selected);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(profileProvider.notifier).save(
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
                          _PickerField(
                            label: l10n.profileEditProfileRoleLabel,
                            icon: Icons.person_outline,
                            value: _role.title,
                            onTap: _selectRole,
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
  const _EditProfileHeader({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: colorScheme.onPrimary,
                        size: 20,
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

  final XFile? file;
  final String? networkAvatarUrl;
  final bool isUploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    ImageProvider? backgroundImage;
    if (file != null) {
      backgroundImage = FileImage(File(file!.path));
    } else if (networkAvatarUrl != null && networkAvatarUrl!.isNotEmpty) {
      backgroundImage = NetworkImage('${ApiConfig.baseUrl}$networkAvatarUrl');
    }

    return Semantics(
      button: true,
      label: l10n.profileEditProfileChangePhoto,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.blushSurface,
                backgroundImage: backgroundImage,
                child: backgroundImage == null
                    ? const Icon(
                        Icons.person,
                        size: 44,
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
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.brandCrimson,
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
      decoration: _fieldDecoration(label: label, icon: icon, hintText: hintText),
      validator: validator,
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: InputDecorator(
          decoration: _fieldDecoration(label: label, icon: icon),
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.warmBlack,
            ),
          ),
        ),
      ),
    );
  }
}

class _RolePickerSheet extends StatelessWidget {
  const _RolePickerSheet({required this.selected});

  final MerchantRole selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.roseDivider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              l10n.profileEditProfileRoleSheetTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.warmBlack,
              ),
            ),
            const SizedBox(height: 16),
            for (final role in MerchantRole.values) ...[
              _RoleOption(
                role: role,
                selected: role == selected,
                onTap: () => Navigator.of(context).pop(role),
              ),
              if (role != MerchantRole.values.last) const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final MerchantRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected ? AppColors.blushSurface : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.brandCrimson : AppColors.roseDivider,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.blushSurface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(role.icon, size: 20, color: AppColors.brandCrimson),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.warmBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      role.subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.warmTaupe,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: AppColors.brandCrimson,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
