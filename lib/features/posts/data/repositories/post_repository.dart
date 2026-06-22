import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/alias_generator.dart';
import '../models/post_model.dart';

/// Selects posts joined with author + reaction/comment aggregates.
/// Relies on the `posts_with_meta` view defined in supabase/schema.sql,
/// which already excludes hidden posts for non-moderators via RLS.
const _postSelect = '''
  *,
  author:author_id ( username, display_name, avatar_url, role ),
  community:community_id ( name )
''';

class PostRepository {
  final SupabaseClient _client;
  PostRepository(this._client);

  Map<String, dynamic> _flatten(Map<String, dynamic> row) {
    final author = row['author'] as Map<String, dynamic>?;
    final community = row['community'] as Map<String, dynamic>?;
    return {
      ...row,
      'author_username': author?['username'],
      'author_display_name': author?['display_name'],
      'author_avatar_url': author?['avatar_url'],
      'author_role': author?['role'],
      'community_name': community?['name'],
    };
  }

  Future<Either<Failure, List<PostModel>>> getFeed({
    String? communityId,
    bool anonymousOnly = false,
    bool trending = false,
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      var query = _client.from(Tables.posts).select(_postSelect).eq('is_hidden', false);
      if (communityId != null) query = query.eq('community_id', communityId);
      if (anonymousOnly) query = query.eq('is_anonymous', true);

      final from = page * pageSize;
      final to = from + pageSize - 1;
      final ordered = trending
          ? query.order('comment_count', ascending: false).order('created_at', ascending: false)
          : query.order('is_pinned', ascending: false).order('created_at', ascending: false);
      final data = await ordered.range(from, to);
      final posts = (data as List)
          .map((e) => PostModel.fromJson(_flatten(e as Map<String, dynamic>)))
          .toList();
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PostModel>> getPostById(String id) async {
    try {
      final data = await _client.from(Tables.posts).select(_postSelect).eq('id', id).single();
      return Right(PostModel.fromJson(_flatten(data)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, PostModel>> createPost({
    required String authorId,
    String? communityId,
    required String title,
    required String body,
    PostType type = PostType.discussion,
    List<String> tags = const [],
    bool isAnonymous = false,
    List<String> mediaUrls = const [],
  }) async {
    try {
      String? alias;
      if (isAnonymous) {
        // Reuse an existing alias for this user+community if one exists,
        // otherwise mint a new one and persist it (see anonymous_profiles
        // table). This keeps a user's anonymous identity consistent within
        // the same community thread without exposing it to moderators.
        final existing = await _client
            .from(Tables.anonymousProfiles)
            .select('alias')
            .eq('user_id', authorId)
            .filter('community_id', communityId == null ? 'is' : 'eq', communityId ?? '')
            .maybeSingle();
        if (existing != null) {
          alias = existing['alias'] as String;
        } else {
          alias = AliasGenerator.generate();
          await _client.from(Tables.anonymousProfiles).insert({
            'user_id': authorId,
            'community_id': communityId,
            'alias': alias,
          });
        }
      }

      final post = PostModel(
        id: '',
        authorId: authorId,
        communityId: communityId,
        title: title,
        body: body,
        type: type,
        tags: tags,
        isAnonymous: isAnonymous,
        anonymousAlias: alias,
        mediaUrls: mediaUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final data = await _client
          .from(Tables.posts)
          .insert(post.toInsertJson())
          .select(_postSelect)
          .single();
      return Right(PostModel.fromJson(_flatten(data)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> updatePost(String id, {String? title, String? body, List<String>? tags}) async {
    try {
      await _client.from(Tables.posts).update({
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        if (tags != null) 'tags': tags,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> deletePost(String id) async {
    try {
      await _client.from(Tables.posts).delete().eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> toggleSave(String postId, String userId, bool save) async {
    try {
      if (save) {
        await _client.from('saved_posts').insert({'post_id': postId, 'user_id': userId});
      } else {
        await _client.from('saved_posts').delete().match({'post_id': postId, 'user_id': userId});
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<PostModel>>> getSavedPosts(String userId) async {
    try {
      final data = await _client
          .from('saved_posts')
          .select('post:post_id ($_postSelect)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final posts = (data as List)
          .map((e) => PostModel.fromJson(_flatten((e as Map<String, dynamic>)['post'] as Map<String, dynamic>)))
          .toList();
      return Right(posts);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> react(String postId, String userId, ReactionType type) async {
    try {
      await _client.from(Tables.reactions).upsert({
        'target_id': postId,
        'target_type': 'post',
        'user_id': userId,
        'type': type.value,
      }, onConflict: 'target_id,target_type,user_id');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> removeReaction(String postId, String userId) async {
    try {
      await _client
          .from(Tables.reactions)
          .delete()
          .match({'target_id': postId, 'target_type': 'post', 'user_id': userId});
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
