import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/store_address.dart';
import '../providers/store_address_provider.dart';

final _kEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class AddStoreAddressScreen extends ConsumerStatefulWidget {
  const AddStoreAddressScreen({super.key});

  @override
  ConsumerState<AddStoreAddressScreen> createState() =>
      _AddStoreAddressScreenState();
}

class _AddStoreAddressScreenState extends ConsumerState<AddStoreAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _fullAddressController = TextEditingController();
  final _districtController = TextEditingController();
  final _provinceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _hoursController = TextEditingController();
  bool _isDefault = true;

  @override
  void dispose() {
    _labelController.dispose();
    _storeNameController.dispose();
    _businessTypeController.dispose();
    _fullAddressController.dispose();
    _districtController.dispose();
    _provinceController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  String? _required(String? value, AppLocalizations l10n) =>
      (value == null || value.trim().isEmpty)
      ? l10n.storeAddressFieldRequiredError
      : null;

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(storeAddressBookProvider.notifier)
        .addAddress(
          StoreAddress(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            label: _labelController.text.trim(),
            storeName: _storeNameController.text.trim(),
            businessType: _businessTypeController.text.trim(),
            fullAddress: _fullAddressController.text.trim(),
            district: _districtController.text.trim(),
            province: _provinceController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            operatingHours: _hoursController.text.trim(),
            isDefault: _isDefault,
          ),
        );
    context.pop();
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
          _Header(colorScheme: colorScheme, textTheme: textTheme),
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
                    _AppTextField(
                      label: l10n.storeAddressLabelFieldLabel,
                      controller: _labelController,
                      hintText: l10n.storeAddressLabelFieldHint,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => _required(value, l10n),
                    ),
                    const SizedBox(height: 20),
                    _AppTextField(
                      label: l10n.storeAddressNameFieldLabel,
                      controller: _storeNameController,
                      hintText: l10n.storeAddressNameFieldHint,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => _required(value, l10n),
                    ),
                    const SizedBox(height: 20),
                    _AppTextField(
                      label: l10n.storeAddressBusinessTypeFieldLabel,
                      controller: _businessTypeController,
                      hintText: l10n.storeAddressBusinessTypeFieldHint,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => _required(value, l10n),
                    ),
                    const SizedBox(height: 20),
                    _AppTextField(
                      label: l10n.storeAddressFullAddressFieldLabel,
                      controller: _fullAddressController,
                      hintText: l10n.storeAddressFullAddressFieldHint,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      validator: (value) => _required(value, l10n),
                    ),
                    const SizedBox(height: 20),
                    _AppTextField(
                      label: l10n.storeAddressDistrictFieldLabel,
                      controller: _districtController,
                      hintText: l10n.storeAddressDistrictFieldHint,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => _required(value, l10n),
                    ),
                    const SizedBox(height: 20),
                    _AppTextField(
                      label: l10n.storeAddressProvinceFieldLabel,
                      controller: _provinceController,
                      hintText: l10n.storeAddressProvinceFieldHint,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) => _required(value, l10n),
                    ),
                    const SizedBox(height: 20),
                    _AppTextField(
                      label: l10n.storeAddressPhoneFieldLabel,
                      controller: _phoneController,
                      hintText: l10n.storeAddressPhoneFieldHint,
                      keyboardType: TextInputType.phone,
                      validator: (value) => _required(value, l10n),
                    ),
                    const SizedBox(height: 20),
                    _AppTextField(
                      label: l10n.storeAddressEmailFieldLabel,
                      controller: _emailController,
                      hintText: l10n.storeAddressEmailFieldHint,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        if (trimmed.isEmpty) {
                          return l10n.storeAddressFieldRequiredError;
                        }
                        if (!_kEmailPattern.hasMatch(trimmed)) {
                          return l10n.storeAddressEmailInvalidError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _AppTextField(
                      label: l10n.storeAddressHoursFieldLabel,
                      controller: _hoursController,
                      hintText: l10n.storeAddressHoursFieldHint,
                      validator: (value) => _required(value, l10n),
                    ),
                    const SizedBox(height: 20),
                    _DefaultAddressToggle(
                      isDefault: _isDefault,
                      onChanged: (value) => setState(() => _isDefault = value),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(
                        l10n.storeAddressSaveButton,
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
                    onTap: () => context.canPop()
                        ? context.pop()
                        : context.goNamed('profile'),
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
                  l10n.storeAddressAddScreenTitle,
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

class _DefaultAddressToggle extends StatelessWidget {
  const _DefaultAddressToggle({
    required this.isDefault,
    required this.onChanged,
  });

  final bool isDefault;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.roseDivider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.storeAddressSetDefaultTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warmBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.storeAddressSetDefaultSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.warmTaupe,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDefault,
            onChanged: onChanged,
            activeTrackColor: AppColors.brandCrimson,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
