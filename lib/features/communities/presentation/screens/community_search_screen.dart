import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../providers/community_provider.dart';

class CommunitySearchScreen extends ConsumerStatefulWidget {
  const CommunitySearchScreen({super.key});
  @override
  ConsumerState<CommunitySearchScreen> createState() => _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends ConsumerState<CommunitySearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(communitiesListProvider(_query.isEmpty ? null : _query));
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search communities...', border: InputBorder.none),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: resultsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => const SizedBox.shrink(),
        data: (results) {
          if (results.isEmpty) {
            return const EmptyState(icon: Icons.search_off_rounded, title: 'No communities found');
          }
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (_, i) {
              final c = results[i];
              return ListTile(
                leading: UserAvatar(avatarUrl: c.avatarUrl, displayName: c.name, radius: 18),
                title: Text(c.name),
                subtitle: Text('${c.memberCount} members'),
                onTap: () => context.push('/communities/${c.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
