import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/merchant_role.dart';

const _kStoreTypes = [
  'Physical Store',
  'Online Store',
  'Both Physical & Online',
];

const _kProvinces = [
  'Phnom Penh',
  'Kandal',
  'Siem Reap',
  'Battambang',
  'Kampong Cham',
  'Preah Sihanouk',
];

const _kDistricts = [
  'Khan Chamkarmon',
  'Khan Toul Kork',
  'Khan Sen Sok',
  'Khan Boeng Keng Kang',
  'Other',
];

const _kMaxStorePhotos = 3;

class BusinessInfoScreen extends StatefulWidget {
  const BusinessInfoScreen({required this.role, super.key});

  final MerchantRole role;

  @override
  State<BusinessInfoScreen> createState() => _BusinessInfoScreenState();
}

class _BusinessInfoScreenState extends State<BusinessInfoScreen> {
  final _shopNameController = TextEditingController();
  final _storeUrlController = TextEditingController();
  final _streetController = TextEditingController();
  String? _storeType;
  String? _province;
  String? _district;
  int _storePhotoCount = 0;
  bool _agreed = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _storeUrlController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('personalDetails', extra: widget.role);
    }
  }

  void _addStorePhoto() {
    if (_storePhotoCount >= _kMaxStorePhotos) return;
    setState(() => _storePhotoCount++);
  }

  void _removeStorePhoto(int index) {
    setState(() => _storePhotoCount--);
  }

  void _createAccount() {
    if (!_agreed) return;
    // Mock submit — real KYC/backend wiring lands later.
    context.goNamed('marketplace');
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
            currentStep: widget.role.totalSteps,
            totalSteps: widget.role.totalSteps,
            onBack: _goBack,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FormField(
                      label: 'SHOP / BUSINESS NAME',
                      controller: _shopNameController,
                      hintText: 'e.g. Angkor Wholesale Co.',
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
                    _StorePhotosField(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      photoCount: _storePhotoCount,
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
                      items: _kProvinces,
                      onChanged: (value) => setState(() => _province = value),
                    ),
                    const SizedBox(height: 20),
                    _DropdownField(
                      label: 'DISTRICT / SANGKAT',
                      hintText: 'Select district...',
                      value: _district,
                      items: _kDistricts,
                      onChanged: (value) => setState(() => _district = value),
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'STREET ADDRESS',
                      controller: _streetController,
                      hintText: 'e.g. Street 271, Phnom Penh',
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
                      onPressed: _agreed ? _createAccount : null,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Create my Account'),
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
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 16,
          24,
          24,
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
  }) : keyboardType = null;

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: textTheme.bodyLarge,
      decoration: InputDecoration(
        filled: false,
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
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
      initialValue: value,
      icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
      style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        filled: false,
        labelText: label,
        hintText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _StorePhotosField extends StatelessWidget {
  const _StorePhotosField({
    required this.colorScheme,
    required this.textTheme,
    required this.photoCount,
    required this.onAdd,
    required this.onRemove,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final int photoCount;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
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
          onTap: onAdd,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
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
                  child: Icon(Icons.camera_alt_outlined, color: colorScheme.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tap to upload store photos',
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
          children: List.generate(_kMaxStorePhotos, (index) {
            final filled = index < photoCount;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == _kMaxStorePhotos - 1 ? 0 : 12,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: InkWell(
                    onTap: filled ? () => onRemove(index) : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: filled
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest.withValues(
                                alpha: 0.4,
                              ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Icon(
                        filled ? Icons.check_circle : Icons.image_outlined,
                        color: filled
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
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
