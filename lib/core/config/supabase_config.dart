import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_config.dart';

/// Initializes the Supabase client. Call once in main() before runApp().
class SupabaseConfig {
  SupabaseConfig._();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        eventsPerSecond: 10,
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => client.auth.currentUser?.id;
  static bool get isAuthenticated => client.auth.currentUser != null;
}
