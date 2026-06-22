import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import '../../auth/data/models/app_user_model.dart';

class ProfileRepository {
  final SupabaseClient _client;
  ProfileRepository(this._client);

  Future<Either<Failure, AppUserModel>> getProfile(String userId) async {
    try {
      final data = await _client.from(Tables.users).select().eq('id', userId).single();
      return Right(AppUserModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, AppUserModel>> updateProfile({
    required String userId,
    String? displayName,
    String? bio,
    String? university,
    String? faculty,
    String? department,
    String? academicLevel,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        if (displayName != null) 'display_name': displayName,
        if (bio != null) 'bio': bio,
        if (university != null) 'university': university,
        if (faculty != null) 'faculty': faculty,
        if (department != null) 'department': department,
        if (academicLevel != null) 'academic_level': academicLevel,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };
      final data = await _client
          .from(Tables.users)
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      return Right(AppUserModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Map<String, int>>> getProfileStats(String userId) async {
    try {
      // Use select with head:true + count to get counts without fetching rows
      final postsRes = await _client
          .from(Tables.posts)
          .select('id', const FetchOptions(count: CountOption.exact, head: true))
          .eq('author_id', userId);
      final commentsRes = await _client
          .from(Tables.comments)
          .select('id', const FetchOptions(count: CountOption.exact, head: true))
          .eq('author_id', userId);
      final communitiesRes = await _client
          .from(Tables.communityMembers)
          .select('community_id', const FetchOptions(count: CountOption.exact, head: true))
          .eq('user_id', userId);

      return Right({
        'posts': postsRes.count ?? 0,
        'comments': commentsRes.count ?? 0,
        'communities': communitiesRes.count ?? 0,
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
