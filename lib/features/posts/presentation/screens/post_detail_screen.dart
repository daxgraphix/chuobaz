import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../comments/presentation/providers/comment_provider.dart';
import '../../../comments/presentation/widgets/comment_tile.dart';
import '../providers/post_provider.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});
  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  String? _replyToId;
  bool _commentAnon = false;
  bool _sending = false;

  Future<void> _sendComment(String postId, String? communityId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _sending = true);
    final result = await ref.read(commentRepositoryProvider).addComment(
          postId: postId,
          authorId: user.id,
          body: text,
          parentId: _replyToId,
          isAnonymous: _commentAnon,
          communityIdForAlias: communityId,
        );
    setState(() => _sending = false);
    result.fold(
      (failure) => context.showSnack(failure.message, isError: true),
      (_) {
        _commentController.clear();
        _replyToId = null;
        ref.invalidate(commentsProvider(postId));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.postId));
    final commentsAsync = ref.watch(commentsProvider(widget.postId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: postAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Failed to load post')),
        data: (post) {
          if (post == null) return const Center(child: Text('Post not found'));
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        UserAvatar(
                          avatarUrl: post.isAnonymous ? null : post.authorAvatarUrl,
                          displayName: post.displayAuthorName,
                          isAnonymous: post.isAnonymous,
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Text(post.displayAuthorName, style: AppTextStyles.labelLarge),
                                if (!post.isAnonymous && post.authorRole != null) ...[
                                  const SizedBox(width: 6),
                                  RoleBadge(role: post.authorRole!, compact: true),
                                ],
                              ]),
                              Text(DateFormatter.full(post.createdAt), style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(post.title, style: AppTextStyles.h2),
                    const SizedBox(height: 8),
                    Text(post.body, style: AppTextStyles.bodyLarge),
                    if (post.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        children: post.tags.map((t) => Chip(label: Text('#$t'))).toList(),
                      ),
                    ],
                    const Divider(height: 32),
                    Row(
                      children: List.generate(ReactionType.values.length, (i) {
                        final type = ReactionType.values[i];
                        final count = post.reactionCounts[type.value] ?? 0;
                        final selected = post.myReaction == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ActionChip(
                            label: Text('${type.emoji} $count'),
                            backgroundColor: selected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12) : null,
                            onPressed: () async {
                              if (user == null) return;
                              final updated = await ref
                                  .read(reactionControllerProvider)
                                  .toggle(post, user.id, type);
                              ref.invalidate(postDetailProvider(widget.postId));
                            },
                          ),
                        );
                      }),
                    ),
                    const Divider(height: 32),
                    Text('Comments (${post.commentCount})', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    commentsAsync.when(
                      loading: () => const InlineLoadingMore(),
                      error: (e, _) => Text('Could not load comments'),
                      data: (comments) {
                        if (comments.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('No comments yet. Be the first!'),
                          );
                        }
                        return Column(
                          children: comments
                              .map((c) => CommentTile(
                                    comment: c,
                                    onReply: () => setState(() => _replyToId = c.id),
                                    onReact: (_) async {
                                      if (user == null) return;
                                      await ref
                                          .read(commentRepositoryProvider)
                                          .react(c.id, user.id, ReactionType.like);
                                      ref.invalidate(commentsProvider(widget.postId));
                                    },
                                  ))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: _replyToId != null ? 'Replying...' : 'Add a comment',
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(_commentAnon ? Icons.theater_comedy : Icons.theater_comedy_outlined),
                        tooltip: 'Comment anonymously',
                        onPressed: () => setState(() => _commentAnon = !_commentAnon),
                      ),
                      _sending
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                          : IconButton(
                              icon: const Icon(Icons.send_rounded),
                              onPressed: () => _sendComment(post.id, post.communityId),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
