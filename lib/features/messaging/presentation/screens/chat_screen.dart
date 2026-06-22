import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/messaging_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;
  final String? otherUsername;
  const ChatScreen({super.key, required this.conversationId, this.otherUsername});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _send() {
    final user = ref.read(currentUserProvider);
    final text = _controller.text.trim();
    if (text.isEmpty || user == null) return;
    ref.read(chatProvider(widget.conversationId).notifier).send(user.id, text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatProvider(widget.conversationId));
    final myId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUsername ?? 'Chat')),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const LoadingIndicator(),
              error: (e, _) => Center(child: Text('$e')),
              data: (messages) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    final isMine = m.senderId == myId;
                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                        decoration: BoxDecoration(
                          color: isMine ? AppColors.primary : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.body, style: AppTextStyles.bodyMedium.copyWith(color: isMine ? Colors.white : null)),
                            const SizedBox(height: 2),
                            Text(DateFormatter.time(m.createdAt),
                                style: AppTextStyles.caption.copyWith(color: isMine ? Colors.white70 : null)),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(hintText: 'Message...', isDense: true),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send_rounded), onPressed: _send),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
