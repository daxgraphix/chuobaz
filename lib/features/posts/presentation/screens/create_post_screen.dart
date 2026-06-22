import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/post_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final String? communityId;
  const CreatePostScreen({super.key, this.communityId});
  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _tags = TextEditingController();
  PostType _type = PostType.discussion;
  bool _isAnonymous = false;
  bool _posting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _posting = true);
    final tags = _tags.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final result = await ref.read(postRepositoryProvider).createPost(
          authorId: user.id,
          communityId: widget.communityId,
          title: _title.text.trim(),
          body: _body.text.trim(),
          type: _type,
          tags: tags,
          isAnonymous: _isAnonymous,
        );
    setState(() => _posting = false);
    if (!mounted) return;
    result.fold(
      (failure) => context.showSnack(failure.message, isError: true),
      (post) {
        context.showSnack('Post published');
        Navigator.pop(context, post);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _posting ? null : _submit,
            child: _posting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Post'),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SegmentedButton<PostType>(
                segments: const [
                  ButtonSegment(value: PostType.discussion, label: Text('Discussion')),
                  ButtonSegment(value: PostType.question, label: Text('Question')),
                  ButtonSegment(value: PostType.poll, label: Text('Poll')),
                ],
                selected: {_type},
                onSelectionChanged: (s) => setState(() => _type = s.first),
              ),
              const SizedBox(height: 20),
              AppTextField(
                controller: _title,
                label: 'Title',
                hint: "What's on your mind?",
                validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _body,
                label: 'Body',
                hint: 'Share details...',
                maxLines: 8,
                validator: (v) => v == null || v.trim().isEmpty ? 'Body is required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(controller: _tags, label: 'Tags (comma separated)', hint: 'e.g. exams, cs101'),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Post anonymously'),
                subtitle: const Text('Your identity will be hidden behind an alias'),
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
