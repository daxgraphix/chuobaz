import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/moderation_provider.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final String targetId;
  final String targetType;
  const ReportScreen({super.key, required this.targetId, required this.targetType});
  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _details = TextEditingController();
  String _reason = 'Spam';
  bool _sending = false;

  final _reasons = const ['Spam', 'Harassment', 'Hate speech', 'Misinformation', 'Inappropriate content', 'Other'];

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _sending = true);
    final result = await ref.read(moderationRepositoryProvider).submitReport(
          reporterId: user.id,
          targetId: widget.targetId,
          targetType: widget.targetType,
          reason: _reason,
          details: _details.text.trim().isEmpty ? null : _details.text.trim(),
        );
    setState(() => _sending = false);
    if (!mounted) return;
    result.fold(
      (failure) => context.showSnack(failure.message, isError: true),
      (_) {
        context.showSnack('Report submitted. Our moderators will review it.');
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Content')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Why are you reporting this?'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reasons
                  .map((r) => ChoiceChip(label: Text(r), selected: _reason == r, onSelected: (_) => setState(() => _reason = r)))
                  .toList(),
            ),
            const SizedBox(height: 16),
            AppTextField(controller: _details, label: 'Additional details (optional)', maxLines: 4),
            const SizedBox(height: 24),
            AppButton(label: 'Submit Report', isLoading: _sending, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
