import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/resource_model.dart';
import '../providers/academic_provider.dart';

/// NOTE: file picking/upload to Supabase Storage is stubbed with a text URL
/// field for now to keep dependencies minimal. Swap in `file_picker` +
/// `supabase.storage.from('academic-resources').upload(...)` when ready.
class UploadResourceScreen extends ConsumerStatefulWidget {
  const UploadResourceScreen({super.key});
  @override
  ConsumerState<UploadResourceScreen> createState() => _UploadResourceScreenState();
}

class _UploadResourceScreenState extends ConsumerState<UploadResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _courseCode = TextEditingController();
  final _description = TextEditingController();
  final _fileUrl = TextEditingController();
  ResourceType _type = ResourceType.studyNote;
  bool _saving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _saving = true);
    final resource = ResourceModel(
      id: '',
      uploaderId: user.id,
      title: _title.text.trim(),
      courseCode: _courseCode.text.trim().toUpperCase(),
      type: _type,
      description: _description.text.trim(),
      fileUrl: _fileUrl.text.trim(),
      createdAt: DateTime.now(),
    );
    final result = await ref.read(academicRepositoryProvider).uploadResource(resource);
    setState(() => _saving = false);
    if (!mounted) return;
    result.fold(
      (failure) => context.showSnack(failure.message, isError: true),
      (_) {
        context.showSnack('Resource shared');
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Resource')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<ResourceType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Resource Type'),
                items: ResourceType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.label))).toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 16),
              AppTextField(controller: _title, label: 'Title', validator: (v) => Validators.required(v, field: 'Title')),
              const SizedBox(height: 16),
              AppTextField(controller: _courseCode, label: 'Course Code', hint: 'e.g. CS101', validator: (v) => Validators.required(v, field: 'Course code')),
              const SizedBox(height: 16),
              AppTextField(controller: _description, label: 'Description', maxLines: 4),
              const SizedBox(height: 16),
              AppTextField(controller: _fileUrl, label: 'File URL', hint: 'Link to PDF/doc', validator: (v) => Validators.required(v, field: 'File URL')),
              const SizedBox(height: 28),
              AppButton(label: 'Share Resource', isLoading: _saving, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
