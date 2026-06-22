import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/post_provider.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final String postId;
  const EditPostScreen({super.key, required this.postId});
  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.postId));
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Post')),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (post) {
          if (post == null) return const Center(child: Text('Post not found'));
          if (!_loaded) {
            _title.text = post.title;
            _body.text = post.body;
            _loaded = true;
          }
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppTextField(controller: _title, label: 'Title'),
                const SizedBox(height: 16),
                AppTextField(controller: _body, label: 'Body', maxLines: 8),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Save Changes',
                  isLoading: _saving,
                  onPressed: () async {
                    setState(() => _saving = true);
                    final result = await ref
                        .read(postRepositoryProvider)
                        .updatePost(post.id, title: _title.text.trim(), body: _body.text.trim());
                    setState(() => _saving = false);
                    if (!mounted) return;
                    result.fold(
                      (failure) => context.showSnack(failure.message, isError: true),
                      (_) {
                        ref.invalidate(postDetailProvider(widget.postId));
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
