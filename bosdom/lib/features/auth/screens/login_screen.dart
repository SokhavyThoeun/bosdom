import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../profile/services/profile_service.dart';
import '../models/merchant_role.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Google sign in completes asynchronously once the web sheet redirects
    // back into the app, so navigation happens here rather than right after
    // AuthService.signInWithGoogle() returns.
    //
    // onAuthStateChange is a ReplaySubject: subscribing here immediately
    // replays whatever the last known auth event was, even if it's stale
    // (e.g. a session from before this screen was reached). Compare against
    // the token seen at mount time so only a genuinely new sign-in navigates.
    final tokenAtMount =
        Supabase.instance.client.auth.currentSession?.accessToken;
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final isNewSignIn =
          data.event == AuthChangeEvent.signedIn &&
          data.session?.accessToken != tokenAtMount;
      // Guard on isCurrent too: this screen isn't popped when the user
      // pushes on to signup, so it stays mounted underneath and would
      // otherwise still react to a sign-in that happens deep in that wizard
      // and force-navigate away from it.
      if (isNewSignIn &&
          mounted &&
          (ModalRoute.of(context)?.isCurrent ?? false)) {
        _routeAfterSignIn();
      }
    });
  }

  /// Sends the user to the marketplace, unless this account has never
  /// finished the signup wizard — in which case it's routed back into it
  /// instead, since a Google sign-in or an interrupted email signup is just
  /// authentication, not a substitute for onboarding. `role` alone isn't
  /// enough to tell those apart (it's saved as early as the
  /// personal-details step); only `onboardingComplete`, set by the wizard's
  /// last step, means the account is actually finished.
  Future<void> _routeAfterSignIn() async {
    var routeName = 'marketplace';
    MerchantRole? role;
    try {
      final profile = await ProfileService.fetch();
      if (!profile.onboardingComplete) {
        if (profile.role.isEmpty) {
          routeName = 'signup';
        } else {
          routeName = 'personalDetails';
          role = MerchantRole.values.byName(profile.role);
        }
      }
    } catch (_) {
      // Backend unreachable or similar transient failure: don't bounce an
      // already-onboarded user into the wizard over a network blip.
    }
    if (!mounted) return;
    if (routeName == 'marketplace') {
      context.goNamed(routeName);
    } else {
      // Push rather than replace, so backing out of the wizard returns to
      // this login screen instead of getting stuck with nowhere to pop to.
      context.pushNamed(routeName, extra: role);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await AuthService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Navigation happens via the onAuthStateChange listener in initState.
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await AuthService.signInWithGoogle();
      // Navigation happens via the onAuthStateChange listener in initState
      // once the web sheet redirects back with a session.
    } catch (error) {
      // The user backing out of the Google sheet isn't an error worth
      // surfacing — just quietly return them to the login screen.
      if (error is GoogleSignInException &&
          error.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
      _showError(error);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FieldLabel(l10n.authLoginEmailLabel, textTheme: textTheme),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: l10n.authLoginEmailHint,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14, right: 6),
                          child: Icon(
                            Icons.email_outlined,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FieldLabel(
                      l10n.authLoginPasswordLabel,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: l10n.authLoginPasswordHint,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 14, right: 6),
                          child: Icon(
                            Icons.lock_outline,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.authLoginPasswordResetComingSoon,
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.authLoginForgotPassword,
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(l10n.authLoginSignInButton),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.authLoginOrSignUpWith,
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
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(l10n.authLoginGoogleButton),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            l10n.authLoginNewMerchantPrompt,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.pushNamed('signup'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              l10n.authLoginCreateAccount,
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
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
    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 14,
          24,
          26,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Image.asset('assets/images/bosdom-logo-white.png'),
                ),
                const SizedBox(width: 12),
                Text(
                  'BosDom',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome back\nMerchant',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sign in to your wholesale account',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.textTheme});

  final String text;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}
