import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../data/analytics_repository.dart';

final analyticsRepositoryProvider = Provider((ref) => AnalyticsRepository(ref.watch(supabaseClientProvider)));

final platformMetricsProvider = FutureProvider<PlatformMetrics>((ref) async {
  final result = await ref.watch(analyticsRepositoryProvider).getMetrics();
  return result.fold((failure) => const PlatformMetrics(), (m) => m);
});
