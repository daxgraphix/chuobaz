import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository.dart';

final postRepositoryProvider = Provider((ref) => PostRepository(ref.watch(supabaseClientProvider)));

enum FeedFilter { latest, trending, anonymous, personalized }

class FeedParams {
  final String? communityId;
  final FeedFilter filter;
  const FeedParams({this.communityId, this.filter = FeedFilter.latest});
}

class FeedNotifier extends StateNotifier<AsyncValue<List<PostModel>>> {
  final PostRepository _repo;
  final FeedParams params;
  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;

  FeedNotifier(this._repo, this.params) : super(const AsyncValue.loading()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = const AsyncValue.loading();
    _page = 0;
    _hasMore = true;
    final result = await _repo.getFeed(
      communityId: params.communityId,
      anonymousOnly: params.filter == FeedFilter.anonymous,
      trending: params.filter == FeedFilter.trending,
      page: 0,
    );
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (posts) {
        _hasMore = posts.length == 20;
        state = AsyncValue.data(posts);
      },
    );
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    final current = state.valueOrNull ?? [];
    final result = await _repo.getFeed(
      communityId: params.communityId,
      anonymousOnly: params.filter == FeedFilter.anonymous,
      trending: params.filter == FeedFilter.trending,
      page: _page + 1,
    );
    result.fold((failure) {}, (posts) {
      _page++;
      _hasMore = posts.length == 20;
      state = AsyncValue.data([...current, ...posts]);
    });
    _loadingMore = false;
  }

  void updatePostInPlace(PostModel updated) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(
        current.map((p) => p.id == updated.id ? updated : p).toList());
  }

  void removePost(String postId) {
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data(current.where((p) => p.id != postId).toList());
  }
}

final feedProvider = StateNotifierProvider.family<FeedNotifier, AsyncValue<List<PostModel>>, FeedParams>(
  (ref, params) => FeedNotifier(ref.watch(postRepositoryProvider), params),
);

final postDetailProvider = FutureProvider.family<PostModel?, String>((ref, postId) async {
  final result = await ref.watch(postRepositoryProvider).getPostById(postId);
  return result.fold((failure) => null, (post) => post);
});

class ReactionController {
  final PostRepository repo;
  ReactionController(this.repo);

  Future<PostModel> toggle(PostModel post, String userId, ReactionType type) async {
    final counts = Map<String, int>.from(post.reactionCounts);
    if (post.myReaction == type) {
      counts[type.value] = (counts[type.value] ?? 1) - 1;
      await repo.removeReaction(post.id, userId);
      return post.copyWith(reactionCounts: counts, clearMyReaction: true);
    } else {
      if (post.myReaction != null) {
        counts[post.myReaction!.value] = (counts[post.myReaction!.value] ?? 1) - 1;
      }
      counts[type.value] = (counts[type.value] ?? 0) + 1;
      await repo.react(post.id, userId, type);
      return post.copyWith(reactionCounts: counts, myReaction: type);
    }
  }
}

final reactionControllerProvider =
    Provider((ref) => ReactionController(ref.watch(postRepositoryProvider)));
