import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';

abstract final class AuthService {
  static GoTrueClient get _auth => Supabase.instance.client.auth;

  static bool _googleSignInInitialized = false;

  static Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone, 'role': role},
    );
    if (response.session == null) {
      throw Exception('Sign up failed');
    }
  }

  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.session == null) {
      throw Exception('Sign in failed');
    }
  }

  /// On iOS, signs in via Google's own SDK ([GoogleSignIn], which presents
  /// its own native/web-sheet UI) and exchanges the resulting ID token with
  /// Supabase directly — this resolves once sign in completes, unlike the
  /// browser-redirect flow below.
  ///
  /// Falls back to the browser-redirect flow on other platforms, since only
  /// an iOS OAuth client is configured so far (see
  /// [SupabaseConfig.googleIosClientId]).
  static Future<void> signInWithGoogle() async {
    if (Platform.isIOS) {
      await _signInWithGoogleNative();
    } else {
      await _signInWithGoogleOAuthSheet();
    }
  }

  static Future<void> _signInWithGoogleNative() async {
    final googleSignIn = GoogleSignIn.instance;
    if (!_googleSignInInitialized) {
      await googleSignIn.initialize(
        clientId: SupabaseConfig.googleIosClientId,
      );
      _googleSignInInitialized = true;
    }

    final account = await googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw Exception('Google sign in did not return an ID token');
    }

    // The ID token includes an at_hash claim whenever an access token is
    // also issued (which it is here), so Supabase requires that access
    // token too in order to verify it.
    final authorization =
        await account.authorizationClient.authorizationForScopes(['email']) ??
        await account.authorizationClient.authorizeScopes(['email']);

    await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );

    // Unlike the browser-based OAuth flow, this ID token itself carries no
    // name/picture claims for Supabase to store, so user_metadata would
    // otherwise stay empty. GoogleSignInAccount has them locally though, so
    // push them in and refresh the session so the access token our backend
    // decodes (in profile.py) picks them up on the very next request.
    if (account.displayName != null || account.photoUrl != null) {
      await _auth.updateUser(
        UserAttributes(
          data: {
            if (account.displayName != null) 'name': account.displayName,
            if (account.photoUrl != null) 'avatar_url': account.photoUrl,
          },
        ),
      );
      await _auth.refreshSession();
    }
  }

  /// Opens Google sign in as an external browser tab. Supabase redirects back
  /// to [SupabaseConfig.googleAuthRedirectUri] once the user finishes, which
  /// completes the session asynchronously via [_auth.onAuthStateChange]
  /// rather than this call's return value.
  ///
  /// Forces [LaunchMode.externalApplication] rather than relying on
  /// [LaunchMode.platformDefault]: on iOS, url_launcher's platform-default
  /// mode still opens https URLs in an in-app SFSafariViewController, which
  /// fails to complete its load when the page redirects to a non-http custom
  /// URL scheme, which is exactly what happens at the end of this flow
  /// (Supabase's callback redirects to `com.example.bosdom://`).
  static Future<void> _signInWithGoogleOAuthSheet() async {
    await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: SupabaseConfig.googleAuthRedirectUri,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    if (_googleSignInInitialized) {
      await GoogleSignIn.instance.signOut();
    }
  }

  static bool get isSignedIn => _auth.currentSession != null;
}
