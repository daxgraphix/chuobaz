import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'network_info.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseConfig.client;
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(Connectivity());
});

final connectivityStreamProvider = StreamProvider<bool>((ref) {
  return ref.watch(networkInfoProvider).onConnectivityChanged;
});

/// Emits Supabase auth state changes (sign in / sign out / token refresh).
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return SupabaseConfig.auth.onAuthStateChange;
});
