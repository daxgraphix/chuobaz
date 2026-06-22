import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../data/models/report_model.dart';
import '../../data/moderation_repository.dart';

final moderationRepositoryProvider = Provider((ref) => ModerationRepository(ref.watch(supabaseClientProvider)));

final reportsProvider = FutureProvider.family<List<ReportModel>, ReportStatus?>((ref, status) async {
  final result = await ref.watch(moderationRepositoryProvider).getReports(status: status);
  return result.fold((failure) => throw failure.message, (list) => list);
});
