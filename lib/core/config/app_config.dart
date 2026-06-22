/// Central app configuration.
///
/// IMPORTANT: Replace the Supabase values below with your own project
/// credentials before running the app. Get them from:
/// Supabase Dashboard -> Project Settings -> API
class AppConfig {
  AppConfig._();

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://YOUR_PROJECT_REF.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY',
  );

  static const String appName = 'ChuoBaz';
  static const String appVersion = '1.0.0';

  // Storage bucket names (create these in Supabase Storage)
  static const String avatarsBucket = 'avatars';
  static const String postMediaBucket = 'post-media';
  static const String marketplaceBucket = 'marketplace-media';
  static const String resourcesBucket = 'academic-resources';

  // Pagination
  static const int defaultPageSize = 20;

  // Feature flags
  static const bool enableGoogleSignIn = true;
  static const bool enableAppleSignIn = true;
}
