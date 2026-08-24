import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/merchant_role.dart';

const _kProvinces = [
  'Phnom Penh',
  'Kandal',
  'Siem Reap',
  'Battambang',
  'Kampong Cham',
  'Preah Sihanouk',
];

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({required this.role, super.key});

  final MerchantRole role;

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final _houseController = TextEditingController();
  final _sangkatController = TextEditingController();
  final _landmarkController = TextEditingController();
  String? _province;
  bool _agreed = false;

  @override
  void dispose() {
    _houseController.dispose();
    _sangkatController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('personalDetails', extra: widget.role);
    }
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
                    _IntroBanner(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 24),
                    _FormField(
                      label: 'HOUSE / STREET NUMBER',
                      controller: _houseController,
                      hintText: 'e.g. #12, Street 271',
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'SANGKAT / DISTRICT',
                      controller: _sangkatController,
                      hintText: 'e.g. Sangkat Tomnob Tuek',
                    ),
                    const SizedBox(height: 20),
                    _ProvinceField(
                      value: _province,
                      onChanged: (value) => setState(() => _province = value),
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'NEAREST LANDMARK (OPTIONAL)',
                      controller: _landmarkController,
                      hintText: 'e.g. Near Lucky Mall',
                    ),
                    const SizedBox(height: 20),
                    _AgreementRow(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      agreed: _agreed,
                      onChanged: (value) => setState(() => _agreed = value),
                    ),
                    const SizedBox(height: 20),
                    _VerificationNote(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _agreed ? _createAccount : null,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Create My Account'),
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
              'Personal Details',
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

class _IntroBanner extends StatelessWidget {
  const _IntroBanner({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Delivery Address',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter your delivery address below.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
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

class _ProvinceField extends StatelessWidget {
  const _ProvinceField({required this.value, required this.onChanged});

  final String? value;
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
        labelText: 'PROVINCE / CITY',
        hintText: 'Select province...',
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
      items: _kProvinces
          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
          .toList(),
      onChanged: onChanged,
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
                      text: ' and confirm I am a merchant in Cambodia.',
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

class _VerificationNote extends StatelessWidget {
  const _VerificationNote({required this.colorScheme, required this.textTheme});

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
                  const TextSpan(
                    text: 'You can start browsing and buying immediately. '
                        'Optionally upload your business ID later in ',
                  ),
                  TextSpan(
                    text: 'Profile → Verification',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' to unlock the '),
                  TextSpan(
                    text: 'Verified Buyer',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' badge.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
