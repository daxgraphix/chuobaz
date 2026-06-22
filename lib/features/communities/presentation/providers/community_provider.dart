import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/community_repository.dart';
import '../../data/models/community_model.dart';

final communityRepositoryProvider = Provider((ref) => CommunityRepository(ref.watch(supabaseClientProvider)));

final communitiesListProvider =
    FutureProvider.family<List<CommunityModel>, String?>((ref, search) async {
  final userId = ref.watch(currentUserProvider)?.id;
  final result = await ref.watch(communityRepositoryProvider).getCommunities(search: search, userId: userId);
  return result.fold((failure) => throw failure.message, (list) => list);
});

final communityDetailProvider =
    FutureProvider.family<CommunityModel?, String>((ref, id) async {
  final userId = ref.watch(currentUserProvider)?.id;
  final result = await ref.watch(communityRepositoryProvider).getCommunityById(id, userId: userId);
  return result.fold((failure) => null, (c) => c);
});
