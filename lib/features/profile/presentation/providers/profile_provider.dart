import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../../auth/data/models/app_user_model.dart';
import '../../data/profile_repository.dart';

final profileRepositoryProvider = Provider((ref) => ProfileRepository(ref.watch(supabaseClientProvider)));

final userProfileProvider =
    FutureProvider.family<AppUserModel?, String>((ref, userId) async {
  final result = await ref.watch(profileRepositoryProvider).getProfile(userId);
  return result.fold((failure) => null, (user) => user);
});

final profileStatsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, userId) async {
  final result = await ref.watch(profileRepositoryProvider).getProfileStats(userId);
  return result.fold((failure) => {'posts': 0, 'comments': 0, 'communities': 0}, (s) => s);
});
