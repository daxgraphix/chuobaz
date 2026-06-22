import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../../../posts/presentation/providers/post_provider.dart';
import '../../../posts/presentation/widgets/post_card.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});
  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _filters = [FeedFilter.latest, FeedFilter.trending, FeedFilter.anonymous];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChuoBaz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => context.push('/notifications'),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text('$unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 9), textAlign: TextAlign.center),
                ),
              ),
          ]),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Latest'), Tab(text: 'Trending'), Tab(text: 'Anonymous')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _filters.map((filter) => _FeedTab(filter: filter)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/create-post'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FeedTab extends ConsumerStatefulWidget {
  final FeedFilter filter;
  const _FeedTab({required this.filter});
  @override
  ConsumerState<_FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<_FeedTab> {
  final _scrollController = ScrollController();
  late final FeedParams params = FeedParams(filter: widget.filter);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 300) {
        ref.read(feedProvider(params).notifier).loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider(params));
    final userId = ref.watch(currentUserProvider)?.id;

    return RefreshIndicator(
      onRefresh: () async => ref.read(feedProvider(params).notifier).loadInitial(),
      child: feedState.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('$e')),
        data: (posts) {
          if (posts.isEmpty) {
            return const EmptyState(
              icon: Icons.dynamic_feed_outlined,
              title: 'No posts yet',
              subtitle: 'Follow communities or create the first post',
            );
          }
          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
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
                  ref.read(feedProvider(params).notifier).updatePostInPlace(updated);
                },
                onSave: () async {
                  if (userId == null) return;
                  await ref.read(postRepositoryProvider).toggleSave(post.id, userId, true);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
                  }
                },
                onReport: () => context.push('/report?targetId=${post.id}&targetType=post'),
              );
            },
          );
        },
      ),
    );
  }
}
