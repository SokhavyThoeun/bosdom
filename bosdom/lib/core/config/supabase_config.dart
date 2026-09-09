abstract final class SupabaseConfig {
  static const url = 'https://fujpxgbkjequrwzxjrcu.supabase.co';
  static const anonKey = 'sb_publishable_Sr0WDt4jrxeo1dPqmNpB-g_EeeeAsmw';

  // Deep link Supabase redirects back to once the Google OAuth web sheet
  // finishes. Used on Android, which has no native Google client configured
  // yet. Must also be registered as a Redirect URL in the Supabase
  // dashboard (Authentication > URL Configuration) and as a custom URL
  // scheme in the AndroidManifest.xml.
  static const googleAuthRedirectUri = 'com.example.bosdom://login-callback/';

  // iOS OAuth client (Google Cloud Console > APIs & Services > Credentials).
  // Used to sign in natively via google_sign_in instead of the browser-based
  // OAuth sheet above. Must be listed in Supabase's Google provider under
  // Authorized Client IDs, and its reversed form registered as a URL scheme
  // in the iOS Info.plist.
  static const googleIosClientId =
      '443899746764-pn8co0kshvbcvnpf3foqimfgr04070qh.apps.googleusercontent.com';
}
