import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_text_styles.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.bar_chart_rounded, 'Analytics', 'Platform-wide metrics & growth', '/admin/analytics'),
      (Icons.shield_outlined, 'Moderation', 'Reports, mutes, content actions', '/admin/moderation'),
      (Icons.manage_accounts_outlined, 'User Management', 'Roles, verification, suspensions', '/admin/users'),
      (Icons.groups_outlined, 'Communities', 'Manage university/faculty groups', '/communities'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Console')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final item = items[i];
          return Card(
            child: ListTile(
              leading: Icon(item.$1, size: 28),
              title: Text(item.$2, style: AppTextStyles.labelLarge),
              subtitle: Text(item.$3),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(item.$4),
            ),
          );
        },
      ),
    );
  }
}
