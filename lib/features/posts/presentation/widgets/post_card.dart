import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../data/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback onTap;
  final void Function(ReactionType type) onReact;
  final VoidCallback? onSave;
  final VoidCallback? onReport;
  final bool isSaved;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onReact,
    this.onSave,
    this.onReport,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UserAvatar(
                    avatarUrl: post.isAnonymous ? null : post.authorAvatarUrl,
                    displayName: post.displayAuthorName,
                    isAnonymous: post.isAnonymous,
                    radius: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(post.displayAuthorName,
                                  style: AppTextStyles.labelLarge, overflow: TextOverflow.ellipsis),
                            ),
                            if (!post.isAnonymous && post.authorRole != null) ...[
                              const SizedBox(width: 6),
                              RoleBadge(role: post.authorRole!, compact: true),
                            ],
                          ],
                        ),
                        Text(
                          post.communityName != null
                              ? '${post.communityName} • ${DateFormatter.relative(post.createdAt)}'
                              : DateFormatter.relative(post.createdAt),
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                  if (post.isPinned)
                    const Icon(Icons.push_pin_rounded, size: 16, color: AppColors.secondary),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, size: 20),
                    onSelected: (v) {
                      if (v == 'save') onSave?.call();
                      if (v == 'report') onReport?.call();
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'save', child: Text(isSaved ? 'Unsave' : 'Save')),
                      const PopupMenuItem(value: 'report', child: Text('Report')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (post.title.isNotEmpty)
                Text(post.title, style: AppTextStyles.h3, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(post.body, style: AppTextStyles.bodyMedium, maxLines: 4, overflow: TextOverflow.ellipsis),
              if (post.tags.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: post.tags
                      .map((t) => Chip(
                            label: Text('#$t', style: AppTextStyles.caption),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  _ReactionButton(
                    icon: post.myReaction != null ? Icons.favorite : Icons.favorite_border,
                    color: post.myReaction != null ? AppColors.accent : null,
                    count: post.totalReactions,
                    onTap: () => onReact(ReactionType.like),
                  ),
                  const SizedBox(width: 20),
                  _ReactionButton(
                    icon: Icons.mode_comment_outlined,
                    count: post.commentCount,
                    onTap: onTap,
                  ),
                  const SizedBox(width: 20),
                  Icon(Icons.share_outlined, size: 18, color: AppColors.lightTextSecondary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final int count;
  final VoidCallback onTap;
  const _ReactionButton({required this.icon, this.color, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.lightTextSecondary),
          const SizedBox(width: 4),
          Text('$count', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
