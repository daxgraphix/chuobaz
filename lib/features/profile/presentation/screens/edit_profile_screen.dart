import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _displayName;
  late final TextEditingController _bio;
  late final TextEditingController _university;
  late final TextEditingController _faculty;
  late final TextEditingController _department;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _displayName = TextEditingController(text: user?.displayName ?? '');
    _bio = TextEditingController(text: user?.bio ?? '');
    _university = TextEditingController(text: user?.university ?? '');
    _faculty = TextEditingController(text: user?.faculty ?? '');
    _department = TextEditingController(text: user?.department ?? '');
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _saving = true);
    final result = await ref.read(profileRepositoryProvider).updateProfile(
          userId: user.id,
          displayName: _displayName.text.trim(),
          bio: _bio.text.trim(),
          university: _university.text.trim(),
          faculty: _faculty.text.trim(),
          department: _department.text.trim(),
        );
    setState(() => _saving = false);
    if (!mounted) return;
    result.fold(
      (failure) => context.showSnack(failure.message, isError: true),
      (_) {
        ref.invalidate(userProfileProvider(user.id));
        context.showSnack('Profile updated');
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppTextField(controller: _displayName, label: 'Display Name'),
            const SizedBox(height: 16),
            AppTextField(controller: _bio, label: 'Bio', maxLines: 3),
            const SizedBox(height: 16),
            AppTextField(controller: _university, label: 'University'),
            const SizedBox(height: 16),
            AppTextField(controller: _faculty, label: 'Faculty'),
            const SizedBox(height: 16),
            AppTextField(controller: _department, label: 'Department'),
            const SizedBox(height: 28),
            AppButton(label: 'Save Changes', isLoading: _saving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
