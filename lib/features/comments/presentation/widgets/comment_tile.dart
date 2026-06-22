import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../data/models/comment_model.dart';

class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onReply;
  final void Function(String emoji)? onReact;
  final int depth;

  const CommentTile({
    super.key,
    required this.comment,
    this.onReply,
    this.onReact,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 24.0, top: 10, bottom: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(
                avatarUrl: comment.isAnonymous ? null : comment.authorAvatarUrl,
                displayName: comment.displayAuthorName,
                isAnonymous: comment.isAnonymous,
                radius: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(comment.displayAuthorName,
                              style: AppTextStyles.labelLarge),
                          if (!comment.isAnonymous && comment.authorRole != null) ...[
                            const SizedBox(width: 6),
                            RoleBadge(role: comment.authorRole!, compact: true),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(comment.body, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 42, top: 4),
            child: Row(
              children: [
                Text(DateFormatter.relative(comment.createdAt), style: AppTextStyles.caption),
                const SizedBox(width: 14),
                if (comment.totalReactions > 0) ...[
                  Text('👍 ${comment.totalReactions}', style: AppTextStyles.caption),
                  const SizedBox(width: 14),
                ],
                GestureDetector(
                  onTap: onReply,
                  child: Text('Reply',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => onReact?.call('like'),
                  child: Text('Like',
                      style: AppTextStyles.caption.copyWith(
                          color: comment.myReaction != null
                              ? AppColors.primary
                              : null)),
                ),
              ],
            ),
          ),
          for (final reply in comment.replies)
            CommentTile(comment: reply, onReply: onReply, onReact: onReact, depth: depth + 1),
        ],
      ),
    );
  }
}

extension on CommentModel {
  int get totalReactions => reactionCounts.values.fold(0, (a, b) => a + b);
}
