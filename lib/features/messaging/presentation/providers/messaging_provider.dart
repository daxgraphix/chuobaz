import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../data/messaging_repository.dart';
import '../../data/models/message_model.dart';

final messagingRepositoryProvider = Provider((ref) => MessagingRepository(ref.watch(supabaseClientProvider)));

final conversationsProvider = FutureProvider.family<List<ConversationModel>, String>((ref, userId) async {
  final result = await ref.watch(messagingRepositoryProvider).getConversations(userId);
  return result.fold((failure) => throw failure.message, (list) => list);
});

class ChatNotifier extends StateNotifier<AsyncValue<List<MessageModel>>> {
  final MessagingRepository _repo;
  final String conversationId;
  RealtimeChannel? _channel;

  ChatNotifier(this._repo, this.conversationId) : super(const AsyncValue.loading()) {
    _load();
    _channel = _repo.subscribeToMessages(conversationId, (msg) {
      final current = state.valueOrNull ?? [];
      if (current.any((m) => m.id == msg.id)) return;
      state = AsyncValue.data([...current, msg]);
    });
  }

  Future<void> _load() async {
    final result = await _repo.getMessages(conversationId);
    state = result.fold(
      (failure) => AsyncValue.error(failure.message, StackTrace.current),
      (list) => AsyncValue.data(list),
    );
  }

  Future<void> send(String senderId, String body) async {
    final result = await _repo.sendMessage(conversationId: conversationId, senderId: senderId, body: body);
    result.fold((failure) {}, (msg) {
      final current = state.valueOrNull ?? [];
      if (current.any((m) => m.id == msg.id)) return;
      state = AsyncValue.data([...current, msg]);
    });
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider.family<ChatNotifier, AsyncValue<List<MessageModel>>, String>(
  (ref, conversationId) => ChatNotifier(ref.watch(messagingRepositoryProvider), conversationId),
);
