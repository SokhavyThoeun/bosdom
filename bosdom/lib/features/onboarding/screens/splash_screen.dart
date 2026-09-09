import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../profile/services/profile_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..forward();

    if (Supabase.instance.client.auth.currentSession != null) {
      _routeSignedInUser();
    } else {
      // Covers the Google sign-in redirect landing here before
      // supabase_flutter's deep-link listener has finished exchanging the
      // code for a session.
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((data) {
            if (data.session != null) _routeSignedInUser();
          });
    }
  }

  /// Mirrors `login_screen._routeAfterSignIn`: a signed-in session isn't
  /// enough on its own — a Google account (or an interrupted email signup)
  /// may not have finished the role/personal-details wizard yet, so route
  /// there instead of straight to the marketplace when the profile has no
  /// role set.
  Future<void> _routeSignedInUser() async {
    var hasRole = true;
    try {
      hasRole = (await ProfileService.fetch()).role.isNotEmpty;
    } catch (_) {
      // Backend unreachable or similar transient failure: don't bounce an
      // already-onboarded user into the wizard over a network blip.
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.goNamed(hasRole ? 'marketplace' : 'signup');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _authSubscription?.cancel();
    super.dispose();
  }

  Animation<double> _fade(
    double start,
    double end, {
    Curve curve = Curves.easeOut,
  }) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: curve),
    );
  }

  Animation<Offset> _rise(
    double start,
    double end, {
    Curve curve = Curves.easeOutCubic,
  }) {
    return Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(_fade(start, end, curve: curve));
  }

  @override
  Widget build(BuildContext context) {
    final flashOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.32, curve: Curves.easeOut),
      ),
    );
    final logoOpacity = _fade(0.08, 0.32);
    final logoScale = Tween<double>(begin: 0.35, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 0.55, curve: Curves.elasticOut),
      ),
    );
    final logoSpin = Tween<double>(begin: -0.08, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.08, 0.55, curve: Curves.easeOutBack),
      ),
    );
    final titleFade = _fade(0.32, 0.58);
    final titleRise = _rise(0.32, 0.58);
    final taglineFade = _fade(0.42, 0.68);
    final taglineRise = _rise(0.42, 0.68);
    final badgesFade = _fade(0.52, 0.76);
    final badgesRise = _rise(0.52, 0.76);
    final actionsFade = _fade(0.66, 0.94);
    final actionsRise = _rise(0.66, 0.94);
    final footerFade = _fade(0.84, 1);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.deepBurgundy, AppColors.brandCrimson],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 3),
                    FadeTransition(
                      opacity: logoOpacity,
                      child: ScaleTransition(
                        scale: logoScale,
                        child: RotationTransition(
                          turns: logoSpin,
                          child: const _Logo(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: titleFade,
                      child: SlideTransition(
                        position: titleRise,
                        child: Text(
                          'BosDom',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(
                                fontSize: 40,
                                height: 1,
                                color: AppColors.petalWhite,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: taglineFade,
                      child: SlideTransition(
                        position: taglineRise,
                        child: Text(
                          "Cambodia's Trusted\nWholesale Network",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: AppColors.petalWhite,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FadeTransition(
                      opacity: badgesFade,
                      child: SlideTransition(
                        position: badgesRise,
                        child: const Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _TrustBadge(label: 'Verified'),
                            _TrustBadge(label: 'Secure'),
                            _TrustBadge(label: 'Wholesale'),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(flex: 5),
                    FadeTransition(
                      opacity: actionsFade,
                      child: SlideTransition(
                        position: actionsRise,
                        child: Column(
                          children: [
                            _PressableScale(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () =>
                                        context.goNamed('signup'),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Text('Get Started'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => context.goNamed('login'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.petalWhite,
                              ),
                              child: const Text(
                                'Already have an account? Log in',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: footerFade,
                      child: Text(
                        'For registered Cambodian merchants only',
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(
                          color: AppColors.roseMist,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: flashOpacity,
                  builder: (context, child) => Opacity(
                    opacity: flashOpacity.value,
                    child: child,
                  ),
                  child: const ColoredBox(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    const logoSize = 170.0;
    const glowSize = 230.0;

    return SizedBox(
      width: glowSize,
      height: glowSize,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: glowSize,
            height: glowSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.4),
                  Colors.white.withValues(alpha: 0.22),
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0, 0.4, 0.7, 1],
              ),
            ),
          ),
          SizedBox(
            width: logoSize,
            height: logoSize,
            child: Image.asset('assets/images/bosdom-logo-white.png'),
          ),
        ],
      ),
    );
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child});

  final Widget child;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) => setState(() => _pressed = value);

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.petalWhite,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
