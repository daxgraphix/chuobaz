import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../posts/presentation/providers/post_provider.dart';
import '../../../posts/presentation/widgets/post_card.dart';
import '../providers/community_provider.dart';

class CommunityDetailScreen extends ConsumerWidget {
  final String communityId;
  const CommunityDetailScreen({super.key, required this.communityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityAsync = ref.watch(communityDetailProvider(communityId));
    final userId = ref.watch(currentUserProvider)?.id;
    final feedParams = FeedParams(communityId: communityId);
    final feedState = ref.watch(feedProvider(feedParams));

    return Scaffold(
      body: communityAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Failed to load community')),
        data: (community) {
          if (community == null) return const Center(child: Text('Community not found'));
          return RefreshIndicator(
            onRefresh: () async => ref.read(feedProvider(feedParams).notifier).loadInitial(),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 160,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(community.name),
                    background: Container(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (community.description != null) Text(community.description!, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text('${community.memberCount} members', style: AppTextStyles.bodySmall),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () async {
                                if (userId == null) return;
                                final repo = ref.read(communityRepositoryProvider);
                                if (community.isJoined) {
                                  await repo.leaveCommunity(community.id, userId);
                                } else {
                                  await repo.joinCommunity(community.id, userId);
                                }
                                ref.invalidate(communityDetailProvider(communityId));
                              },
                              child: Text(community.isJoined ? 'Joined' : 'Join'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: Divider(height: 1)),
                feedState.when(
                  loading: () => const SliverToBoxAdapter(child: LoadingIndicator()),
                  error: (e, _) => SliverToBoxAdapter(child: Center(child: Text('$e'))),
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: EmptyState(icon: Icons.forum_outlined, title: 'No posts yet', subtitle: 'Be the first to start a discussion'),
                      );
                    }
                    return SliverPadding(
                      padding: const EdgeInsets.all(12),
                      sliver: SliverList.separated(
                        itemCount: posts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final post = posts[i];
                          return PostCard(
                            post: post,
                            onTap: () => context.push('/posts/${post.id}'),
                            onReact: (type) async {
                              if (userId == null) return;
                              final updated = await ref.read(reactionControllerProvider).toggle(post, userId, type);
                              ref.read(feedProvider(feedParams).notifier).updatePostInPlace(updated);
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-post?communityId=$communityId'),
        icon: const Icon(Icons.add),
        label: const Text('Post'),
      ),
    );
  }
}
