import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/community_provider.dart';

class CommunitiesListScreen extends ConsumerWidget {
  const CommunitiesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communitiesAsync = ref.watch(communitiesListProvider(null));
    final userId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/communities/search'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(communitiesListProvider(null)),
        child: communitiesAsync.when(
          loading: () => const LoadingIndicator(),
          error: (e, _) => Center(child: Text('Failed to load communities')),
          data: (communities) {
            if (communities.isEmpty) {
              return const EmptyState(
                icon: Icons.groups_outlined,
                title: 'No communities yet',
                subtitle: 'Check back soon as your campus grows on ChuoBaz',
              );
            }
            final grouped = <CommunityLevel, List<dynamic>>{};
            for (final c in communities) {
              grouped.putIfAbsent(c.level, () => []).add(c);
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final level in CommunityLevel.values)
                  if (grouped[level]?.isNotEmpty == true) ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 8),
                      child: Text(_levelLabel(level), style: AppTextStyles.h3),
                    ),
                    for (final c in grouped[level]!)
                      Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          onTap: () => context.push('/communities/${c.id}'),
                          leading: UserAvatar(avatarUrl: c.avatarUrl, displayName: c.name, radius: 22),
                          title: Text(c.name, style: AppTextStyles.labelLarge),
                          subtitle: Text('${c.memberCount} members', style: AppTextStyles.caption),
                          trailing: OutlinedButton(
                            onPressed: () async {
                              if (userId == null) return;
                              final repo = ref.read(communityRepositoryProvider);
                              if (c.isJoined) {
                                await repo.leaveCommunity(c.id, userId);
                              } else {
                                await repo.joinCommunity(c.id, userId);
                              }
                              ref.invalidate(communitiesListProvider(null));
                            },
                            child: Text(c.isJoined ? 'Joined' : 'Join'),
                          ),
                        ),
                      ),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _levelLabel(CommunityLevel level) => switch (level) {
        CommunityLevel.university => 'University',
        CommunityLevel.faculty => 'Faculty',
        CommunityLevel.department => 'Department',
        CommunityLevel.interestGroup => 'Interest Groups',
      };
}
