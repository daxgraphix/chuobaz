import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/supabase_config.dart';
import 'core/database/local_cache.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

Future<void> main() async {
  WidgetsBinding.ensureInitialized();
  await LocalCache.initialize();
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: ChuoBazApp()));
}

class ChuoBazApp extends ConsumerWidget {
  const ChuoBazApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'ChuoBaz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      routerConfig: router,
    );
  }
}
