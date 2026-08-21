import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/address.dart';
import '../providers/address_provider.dart';

const _kProvinces = [
  'Phnom Penh',
  'Kandal',
  'Siem Reap',
  'Battambang',
  'Kampong Cham',
  'Preah Sihanouk',
];

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key, this.selectionMode = false});

  /// When true, this screen was opened while picking a delivery address for
  /// an in-progress checkout: saving returns straight to the checkout.
  final bool selectionMode;

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _houseController = TextEditingController();
  final _sangkatController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _province = _kProvinces.first;
  bool _isDefault = true;

  @override
  void dispose() {
    _labelController.dispose();
    _houseController.dispose();
    _sangkatController.dispose();
    _landmarkController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('marketplace');
    }
  }

  void _saveAddress() {
    if (!_formKey.currentState!.validate()) return;
    ref
        .read(addressBookProvider.notifier)
        .addAddress(
          Address(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            label: _labelController.text.trim(),
            houseNumber: _houseController.text.trim(),
            sangkat: _sangkatController.text.trim(),
            province: _province ?? _kProvinces.first,
            phone: _phoneController.text.trim(),
            landmark: _landmarkController.text.trim().isEmpty
                ? null
                : _landmarkController.text.trim(),
            isDefault: _isDefault,
          ),
        );
    final popsToReturn = widget.selectionMode ? 2 : 1;
    for (var i = 0; i < popsToReturn && context.canPop(); i++) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Column(
        children: [
          _AddAddressHeader(
            colorScheme: colorScheme,
            textTheme: textTheme,
            onBack: _goBack,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AddressFormField(
                        label: l10n.addressLabelFieldLabel,
                        controller: _labelController,
                        hintText: l10n.addressLabelFieldHint,
                      ),
                      const SizedBox(height: 18),
                      _AddressFormField(
                        label: l10n.addressHouseFieldLabel,
                        controller: _houseController,
                        hintText: l10n.addressHouseFieldHint,
                      ),
                      const SizedBox(height: 18),
                      _AddressFormField(
                        label: l10n.addressSangkatFieldLabel,
                        controller: _sangkatController,
                        hintText: l10n.addressSangkatFieldHint,
                      ),
                      const SizedBox(height: 18),
                      _ProvinceField(
                        value: _province,
                        onChanged: (value) => setState(() => _province = value),
                      ),
                      const SizedBox(height: 18),
                      _AddressFormField(
                        label: l10n.addressLandmarkFieldLabel,
                        controller: _landmarkController,
                        hintText: l10n.addressLandmarkFieldHint,
                        required: false,
                      ),
                      const SizedBox(height: 18),
                      _AddressFormField(
                        label: l10n.addressPhoneFieldLabel,
                        controller: _phoneController,
                        hintText: l10n.addressPhoneFieldHint,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 20),
                      _DefaultAddressToggle(
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                        isDefault: _isDefault,
                        onChanged: (value) =>
                            setState(() => _isDefault = value),
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: _saveAddress,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(l10n.addressSaveButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddAddressHeader extends StatelessWidget {
  const _AddAddressHeader({
    required this.colorScheme,
    required this.textTheme,
    required this.onBack,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
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
                  onTap: onBack,
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
                l10n.addressAddScreenTitle,
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

InputDecoration _addressFieldDecoration(
  BuildContext context, {
  required String label,
  required String hintText,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return InputDecoration(
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
    hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: colorScheme.error),
    ),
  );
}

class _AddressFormField extends StatelessWidget {
  const _AddressFormField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.required = true,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: textTheme.bodyLarge,
      validator: required
          ? (value) => (value == null || value.trim().isEmpty)
                ? l10n.addressFieldRequiredError
                : null
          : null,
      decoration: _addressFieldDecoration(
        context,
        label: label,
        hintText: hintText,
      ),
    );
  }
}

class _ProvinceField extends StatelessWidget {
  const _ProvinceField({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return DropdownButtonFormField<String>(
      initialValue: value,
      icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      decoration: _addressFieldDecoration(
        context,
        label: l10n.addressProvinceFieldLabel,
        hintText: l10n.addressProvinceFieldHint,
      ),
      items: _kProvinces
          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DefaultAddressToggle extends StatelessWidget {
  const _DefaultAddressToggle({
    required this.colorScheme,
    required this.textTheme,
    required this.isDefault,
    required this.onChanged,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isDefault;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.addressSetDefaultTitle,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.addressSetDefaultSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDefault,
            onChanged: onChanged,
            activeTrackColor: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
