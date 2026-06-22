import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/messaging_provider.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id;
    if (userId == null) return const Scaffold(body: LoadingIndicator());
    final conversationsAsync = ref.watch(conversationsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: conversationsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('$e')),
        data: (conversations) {
          if (conversations.isEmpty) {
            return const EmptyState(icon: Icons.chat_bubble_outline, title: 'No conversations yet');
          }
          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final c = conversations[i];
              return ListTile(
                leading: UserAvatar(avatarUrl: c.otherAvatarUrl, displayName: c.otherUsername ?? 'User', radius: 22),
                title: Text(c.otherUsername ?? 'User', style: AppTextStyles.labelLarge),
                subtitle: Text(c.lastMessage ?? 'Say hello 👋', maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: c.lastMessageAt != null
                    ? Text(DateFormatter.relative(c.lastMessageAt!), style: AppTextStyles.caption)
                    : null,
                onTap: () => context.push('/messages/${c.id}?otherUsername=${c.otherUsername ?? ""}'),
              );
            },
          );
        },
      ),
    );
  }
}
