import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import '../../../core/utils/alias_generator.dart';
import 'models/comment_model.dart';

const _commentSelect = '''
  *,
  author:author_id ( username, display_name, avatar_url, role )
''';

class CommentRepository {
  final SupabaseClient _client;
  CommentRepository(this._client);

  Future<Either<Failure, List<CommentModel>>> getComments(String postId) async {
    try {
      final data = await _client
          .from(Tables.comments)
          .select(_commentSelect)
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      final flat = (data as List).map((e) => CommentModel.fromJson(e as Map<String, dynamic>)).toList();
      return Right(buildCommentTree(flat));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, CommentModel>> addComment({
    required String postId,
    required String authorId,
    required String body,
    String? parentId,
    bool isAnonymous = false,
    String? communityIdForAlias,
  }) async {
    try {
      String? alias;
      if (isAnonymous) {
        final existing = await _client
            .from(Tables.anonymousProfiles)
            .select('alias')
            .eq('user_id', authorId)
            .filter('community_id', communityIdForAlias == null ? 'is' : 'eq', communityIdForAlias ?? '')
            .maybeSingle();
        alias = existing != null ? existing['alias'] as String : AliasGenerator.generate();
        if (existing == null) {
          await _client.from(Tables.anonymousProfiles).insert({
            'user_id': authorId,
            'community_id': communityIdForAlias,
            'alias': alias,
          });
        }
      }
      final data = await _client
          .from(Tables.comments)
          .insert({
            'post_id': postId,
            'author_id': authorId,
            'parent_id': parentId,
            'body': body,
            'is_anonymous': isAnonymous,
            'anonymous_alias': alias,
          })
          .select(_commentSelect)
          .single();
      return Right(CommentModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteComment(String id) async {
    try {
      await _client.from(Tables.comments).delete().eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> editComment(String id, String body) async {
    try {
      await _client.from(Tables.comments).update({'body': body}).eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> react(String commentId, String userId, ReactionType type) async {
    try {
      await _client.from(Tables.reactions).upsert({
        'target_id': commentId,
        'target_type': 'comment',
        'user_id': userId,
        'type': type.value,
      }, onConflict: 'target_id,target_type,user_id');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
