import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(AppNotificationType type) => switch (type) {
        AppNotificationType.comment => Icons.mode_comment_outlined,
        AppNotificationType.mention => Icons.alternate_email_rounded,
        AppNotificationType.reaction => Icons.favorite_outline,
        AppNotificationType.moderatorAction => Icons.shield_outlined,
        AppNotificationType.marketplace => Icons.storefront_outlined,
        AppNotificationType.message => Icons.chat_bubble_outline,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('$e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(icon: Icons.notifications_none_rounded, title: 'No notifications yet');
          }
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final n = notifications[i];
              return ListTile(
                tileColor: n.isRead ? null : AppColors.primary.withValues(alpha: 0.04),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(_iconFor(n.type), color: AppColors.primary, size: 20),
                ),
                title: Text(n.title, style: AppTextStyles.labelLarge),
                subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: Text(DateFormatter.relative(n.createdAt), style: AppTextStyles.caption),
                onTap: () {
                  ref.read(notificationsProvider.notifier).markRead(n.id);
                  if (n.targetType == 'post' && n.targetId != null) {
                    context.push('/posts/${n.targetId}');
                  } else if (n.targetType == 'conversation' && n.targetId != null) {
                    context.push('/messages/${n.targetId}');
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
