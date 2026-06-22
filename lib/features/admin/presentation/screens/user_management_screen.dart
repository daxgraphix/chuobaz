import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../providers/admin_provider.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});
  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider(_search.isEmpty ? null : _search));
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(hintText: 'Search users...', border: InputBorder.none),
          onChanged: (v) => setState(() => _search = v),
        ),
      ),
      body: usersAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('$e')),
        data: (users) {
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final u = users[i];
              return ListTile(
                leading: UserAvatar(avatarUrl: u.avatarUrl, displayName: u.displayName ?? u.username, radius: 18),
                title: Row(children: [
                  Flexible(child: Text(u.displayName?.isNotEmpty == true ? u.displayName! : u.username, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 6),
                  RoleBadge(role: u.role, compact: true),
                ]),
                subtitle: Text('@${u.username}', style: AppTextStyles.caption),
                trailing: PopupMenuButton<UserRole>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (role) async {
                    await ref.read(adminRepositoryProvider).setUserRole(u.id, role);
                    ref.invalidate(allUsersProvider(_search.isEmpty ? null : _search));
                  },
                  itemBuilder: (_) => UserRole.values
                      .map((r) => PopupMenuItem(value: r, child: Text('Set as ${r.label}')))
                      .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
