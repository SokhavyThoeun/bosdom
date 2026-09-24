import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/cambodia_locations.dart';
import '../models/store_address.dart';
import '../providers/store_address_provider.dart';

final _kEmailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class AddStoreAddressScreen extends ConsumerStatefulWidget {
  const AddStoreAddressScreen({super.key, this.editing});

  /// When non-null, the form edits this address instead of creating one.
  final StoreAddress? editing;

  @override
  ConsumerState<AddStoreAddressScreen> createState() =>
      _AddStoreAddressScreenState();
}

class _AddStoreAddressScreenState extends ConsumerState<AddStoreAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _businessTypeController = TextEditingController();
  final _houseController = TextEditingController();
  final _streetController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _hoursController = TextEditingController();
  String? _province;
  String? _district;
  String? _sangkat;
  bool _isDefault = true;

  bool get _isEditing => widget.editing != null;

  Map<String, List<String>>? get _districtsForProvince =>
      kCambodiaDistricts[_province];

  @override
  void initState() {
    super.initState();
    final a = widget.editing;
    if (a == null) return;
    _labelController.text = a.label;
    _storeNameController.text = a.storeName;
    _businessTypeController.text = a.businessType;
    _phoneController.text = a.phone;
    _emailController.text = a.email;
    _hoursController.text = a.operatingHours;
    _province = a.province;
    _isDefault = a.isDefault;
    // fullAddress is stored as 'No. <house>, Street <street>' and district as
    // 'Sangkat <sangkat>, Khan <khan>'; unpack them back into the form.
    final addr = RegExp(r'^No\. (.*), Street (.*)$').firstMatch(a.fullAddress);
    _houseController.text = addr?.group(1) ?? a.fullAddress;
    _streetController.text = addr?.group(2) ?? '';
    final loc = RegExp(r'^Sangkat (.*), Khan (.*)$').firstMatch(a.district);
    _sangkat = loc?.group(1);
    _district = loc?.group(2);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _storeNameController.dispose();
    _businessTypeController.dispose();
    _houseController.dispose();
    _streetController.dispose();
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

    final notifier = ref.read(storeAddressBookProvider.notifier);
    final address = StoreAddress(
      id:
          widget.editing?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      label: _labelController.text.trim(),
      storeName: _storeNameController.text.trim(),
      businessType: _businessTypeController.text.trim(),
      fullAddress:
          'No. ${_houseController.text.trim()}, '
          'Street ${_streetController.text.trim()}',
      district: 'Sangkat $_sangkat, Khan $_district',
      province: _province!,
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      operatingHours: _hoursController.text.trim(),
      isDefault: _isDefault,
    );
    if (_isEditing) {
      notifier.updateAddress(address);
    } else {
      notifier.addAddress(address);
    }
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
          _Header(
            colorScheme: colorScheme,
            textTheme: textTheme,
            title: _isEditing
                ? l10n.storeAddressEditScreenTitle
                : l10n.storeAddressAddScreenTitle,
          ),
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
                      label: l10n.storeAddressHouseFieldLabel,
                      controller: _houseController,
                      hintText: l10n.storeAddressHouseFieldHint,
                      validator: (value) => _required(value, l10n),
                    ),
                    const SizedBox(height: 20),
                    _AppTextField(
                      label: l10n.storeAddressStreetFieldLabel,
                      controller: _streetController,
                      hintText: l10n.storeAddressStreetFieldHint,
                      validator: (value) => _required(value, l10n),
                    ),
                    const SizedBox(height: 20),
                    _AppDropdownField(
                      label: l10n.addressProvinceFieldLabel,
                      hintText: l10n.addressProvinceFieldHint,
                      value: _province,
                      items: kCambodiaProvinces,
                      validator: (value) => _required(value, l10n),
                      onChanged: (value) => setState(() {
                        _province = value;
                        _district = null;
                        _sangkat = null;
                      }),
                    ),
                    const SizedBox(height: 20),
                    _AppDropdownField(
                      label: l10n.addressDistrictFieldLabel,
                      hintText: l10n.addressDistrictFieldHint,
                      value: _district,
                      items: _districtsForProvince?.keys.toList() ?? const [],
                      validator: (value) => _required(value, l10n),
                      onChanged: (value) => setState(() {
                        _district = value;
                        _sangkat = null;
                      }),
                    ),
                    const SizedBox(height: 20),
                    _AppDropdownField(
                      label: l10n.addressSangkatFieldLabel,
                      hintText: l10n.addressSangkatFieldHint,
                      value: _sangkat,
                      items: _district == null
                          ? const []
                          : _districtsForProvince?[_district] ?? const [],
                      validator: (value) => _required(value, l10n),
                      onChanged: (value) => setState(() => _sangkat = value),
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
  const _Header({
    required this.colorScheme,
    required this.textTheme,
    required this.title,
  });

  final String title;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
                  child: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
              Text(
                title,
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
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
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

class _AppDropdownField extends StatelessWidget {
  const _AppDropdownField({
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String hintText;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
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
        DropdownButtonFormField<String>(
          // Keyed on the item list so a cascading parent change resets it.
          key: ValueKey(items),
          initialValue: items.contains(value) ? value : null,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.brandCrimson,
          ),
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.warmBlack,
          ),
          decoration: _fieldDecoration(hintText: hintText),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          validator: validator,
          onChanged: items.isEmpty ? null : onChanged,
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
