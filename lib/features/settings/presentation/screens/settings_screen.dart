import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _SectionHeader('Appearance'),
          ListTile(
            title: const Text('Dark Mode'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (v) => v != null ? notifier.setThemeMode(v) : null,
            ),
          ),
          ListTile(
            title: const Text('Language'),
            trailing: DropdownButton<String>(
              value: settings.language,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: 'English', child: Text('English')),
                DropdownMenuItem(value: 'Swahili', child: Text('Kiswahili')),
              ],
              onChanged: (v) => v != null ? notifier.setLanguage(v) : null,
            ),
          ),
          _SectionHeader('Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            value: settings.notificationsEnabled,
            onChanged: notifier.setNotificationsEnabled,
          ),
          _SectionHeader('Privacy & Security'),
          SwitchListTile(
            title: const Text('Private Profile'),
            subtitle: const Text('Only followers can see your activity'),
            value: settings.privateProfile,
            onChanged: notifier.setPrivateProfile,
          ),
          ListTile(
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/forgot-password'),
          ),
          _SectionHeader('Account'),
          ListTile(
            title: const Text('Edit Profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/profile/edit'),
          ),
          ListTile(
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showConfirmDialog(context,
                  title: 'Sign Out', message: 'Are you sure you want to sign out?', confirmLabel: 'Sign Out', isDestructive: true);
              if (confirmed) {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              }
            },
          ),
          const SizedBox(height: 20),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '${AppConfig.appName} v${snap.data?.version ?? AppConfig.appVersion}',
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(title.toUpperCase(), style: AppTextStyles.labelSmall),
    );
  }
}
