import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/merchant_role.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({required this.role, super.key});

  final MerchantRole role;

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('signup');
    }
  }

  void _continue() {
    if (widget.role == MerchantRole.supplier) {
      context.pushNamed('uploadDocuments', extra: widget.role);
    } else {
      context.pushNamed('deliveryAddress', extra: widget.role);
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
            currentStep: 2,
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
                      label: 'FULL NAME',
                      controller: _fullNameController,
                      hintText: 'Your full name',
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'PHONE NUMBER (+855)',
                      controller: _phoneController,
                      hintText: '012 345 678',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'EMAIL (OPTIONAL)',
                      controller: _emailController,
                      hintText: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'PASSWORD',
                      controller: _passwordController,
                      hintText: 'Create a password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    _FormField(
                      label: 'CONFIRM PASSWORD',
                      controller: _confirmPasswordController,
                      hintText: 'Re-enter your password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _continue,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Continue'),
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

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
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
