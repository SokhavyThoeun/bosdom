import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../profile/models/user_profile.dart';
import '../../profile/services/profile_service.dart';
import '../models/merchant_role.dart';
import '../services/auth_service.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({required this.role, super.key});

  final MerchantRole role;

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  // True once Google sign-in has completed (either before this screen was
  // reached, e.g. via the login screen, or from tapping the Google button
  // below). Password fields and the Google button hide once this is set,
  // since the account is already authenticated.
  bool _isAuthenticated = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _isAuthenticated = AuthService.isSignedIn;
    if (_isAuthenticated) _prefillFromAccount();

    // Google sign-in via the button below completes synchronously on iOS,
    // but on Android it only resolves here, once the browser sheet redirects
    // back into the app — see AuthService.signInWithGoogle.
    final tokenAtMount =
        Supabase.instance.client.auth.currentSession?.accessToken;
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final isNewSignIn =
          data.event == AuthChangeEvent.signedIn &&
          data.session?.accessToken != tokenAtMount;
      if (isNewSignIn && mounted) {
        setState(() => _isAuthenticated = true);
        _prefillFromAccount();
      }
    });
  }

  void _prefillFromAccount() {
    final user = Supabase.instance.client.auth.currentUser;
    final name = user?.userMetadata?['name'] as String?;
    if (_fullNameController.text.isEmpty && name != null) {
      _fullNameController.text = name;
    }
    if (_emailController.text.isEmpty && user?.email != null) {
      _emailController.text = user!.email!;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
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

  void _navigateNext() {
    if (widget.role == MerchantRole.supplier) {
      context.pushNamed('uploadDocuments', extra: widget.role);
    } else {
      context.pushNamed('deliveryAddress', extra: widget.role);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }

  Future<void> _saveProfile() {
    return ProfileService.save(
      UserProfile(
        name: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: widget.role.name,
        email: _emailController.text.trim(),
      ),
    );
  }

  Future<void> _continue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      if (!_isAuthenticated) {
        await AuthService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
          role: widget.role.name,
        );
      }
      await _saveProfile();
      if (mounted) _navigateNext();
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Only authenticates. [_isAuthenticated] flips to true (via the
  /// onAuthStateChange listener in initState, which fires on both platforms)
  /// once it succeeds, which swaps the form into its Google mode; the
  /// [_continue] button above still does the actual profile save.
  Future<void> _continueWithGoogle() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await AuthService.signInWithGoogle();
    } catch (error) {
      _showError(error);
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
            currentStep: 2,
            totalSteps: widget.role.totalSteps,
            onBack: _goBack,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _FormField(
                        label: 'FULL NAME',
                        controller: _fullNameController,
                        hintText: 'Your full name',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _FormField(
                        label: 'PHONE NUMBER (+855)',
                        controller: _phoneController,
                        hintText: '012 345 678',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _FormField(
                        label: 'EMAIL',
                        controller: _emailController,
                        hintText: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      if (!_isAuthenticated) ...[
                        const SizedBox(height: 20),
                        _FormField(
                          label: 'PASSWORD',
                          controller: _passwordController,
                          hintText: 'Create a password',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _FormField(
                          label: 'CONFIRM PASSWORD',
                          controller: _confirmPasswordController,
                          hintText: 'Re-enter your password',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 32),
                      FilledButton(
                        onPressed: _isSubmitting ? null : _continue,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text('Continue'),
                        ),
                      ),
                      if (!_isAuthenticated) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Or Sign Up with',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _isSubmitting ? null : _continueWithGoogle,
                          icon: SvgPicture.asset(
                            'assets/images/google.svg',
                            width: 20,
                            height: 20,
                          ),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text('Sign Up with Google'),
                          ),
                        ),
                      ],
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
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
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
