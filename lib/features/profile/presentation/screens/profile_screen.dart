import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/role_badge.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserProvider);
    final targetId = userId ?? me?.id;
    final isOwnProfile = targetId == me?.id;

    if (targetId == null) {
      return const Scaffold(body: LoadingIndicator());
    }

    final profileAsync = ref.watch(userProfileProvider(targetId));
    final statsAsync = ref.watch(profileStatsProvider(targetId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push('/settings'),
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Failed to load profile: $e')),
        data: (user) {
          if (user == null) return const Center(child: Text('User not found'));
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: UserAvatar(
                    avatarUrl: user.avatarUrl, displayName: user.displayName ?? user.username, radius: 44),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(user.displayName?.isNotEmpty == true ? user.displayName! : user.username,
                    style: AppTextStyles.h2),
              ),
              Center(child: Text('@${user.username}', style: AppTextStyles.bodySmall)),
              const SizedBox(height: 8),
              Center(child: RoleBadge(role: user.role)),
              if (user.bio != null && user.bio!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(user.bio!, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium),
              ],
              const SizedBox(height: 20),
              if (user.university != null)
                _InfoRow(icon: Icons.school_outlined, label: user.university!),
              if (user.faculty != null)
                _InfoRow(icon: Icons.account_balance_outlined, label: user.faculty!),
              if (user.department != null)
                _InfoRow(icon: Icons.apartment_outlined, label: user.department!),
              const SizedBox(height: 20),
              statsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatTile(label: 'Posts', value: stats['posts'] ?? 0),
                    _StatTile(label: 'Comments', value: stats['comments'] ?? 0),
                    _StatTile(label: 'Communities', value: stats['communities'] ?? 0),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (isOwnProfile)
                OutlinedButton.icon(
                  onPressed: () => context.push('/profile/edit'),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
              if (isOwnProfile) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.bodyMedium),
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  const _StatTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('$value', style: AppTextStyles.h2),
      Text(label, style: AppTextStyles.bodySmall),
    ]);
  }
}
