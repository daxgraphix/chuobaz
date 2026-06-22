import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import 'models/community_model.dart';

class CommunityRepository {
  final SupabaseClient _client;
  CommunityRepository(this._client);

  Future<Either<Failure, List<CommunityModel>>> getCommunities({String? search, String? userId}) async {
    try {
      var query = _client.from(Tables.communities).select('*, members:community_members(count)');
      if (search != null && search.isNotEmpty) {
        query = query.ilike('name', '%$search%');
      }
      final data = await query.order('member_count', ascending: false);
      final list = (data as List).map((e) => e as Map<String, dynamic>).toList();

      Set<String> joinedIds = {};
      if (userId != null) {
        final joined = await _client.from(Tables.communityMembers).select('community_id').eq('user_id', userId);
        joinedIds = (joined as List).map((e) => e['community_id'] as String).toSet();
      }

      return Right(list.map((e) {
        final community = CommunityModel.fromJson(e);
        return community.copyWith(isJoined: joinedIds.contains(community.id));
      }).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CommunityModel>> getCommunityById(String id, {String? userId}) async {
    try {
      final data = await _client.from(Tables.communities).select().eq('id', id).single();
      bool joined = false;
      if (userId != null) {
        final m = await _client
            .from(Tables.communityMembers)
            .select()
            .match({'community_id': id, 'user_id': userId}).maybeSingle();
        joined = m != null;
      }
      return Right(CommunityModel.fromJson(data).copyWith(isJoined: joined));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> joinCommunity(String communityId, String userId) async {
    try {
      await _client.from(Tables.communityMembers).insert({'community_id': communityId, 'user_id': userId});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> leaveCommunity(String communityId, String userId) async {
    try {
      await _client.from(Tables.communityMembers).delete().match({'community_id': communityId, 'user_id': userId});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
