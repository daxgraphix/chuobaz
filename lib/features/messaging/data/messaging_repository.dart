import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import 'models/message_model.dart';

class MessagingRepository {
  final SupabaseClient _client;
  MessagingRepository(this._client);

  Future<Either<Failure, List<ConversationModel>>> getConversations(String userId) async {
    try {
      // Relies on the `conversations_with_meta` view (see schema) which
      // resolves `other_user` + `last_message` per conversation for the
      // calling user.
      final data = await _client
          .from('conversations_with_meta')
          .select()
          .contains('participant_ids', [userId])
          .order('last_message_at', ascending: false);
      return Right((data as List)
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>, userId))
          .toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, String>> getOrCreateConversation(String userA, String userB) async {
    try {
      final result = await _client.rpc('get_or_create_conversation', params: {
        'user_a': userA,
        'user_b': userB,
      });
      return Right(result as String);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<MessageModel>>> getMessages(String conversationId) async {
    try {
      final data = await _client
          .from(Tables.messages)
          .select()
          .eq('conversation_id', conversationId)
          .order('created_at', ascending: true);
      return Right((data as List).map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, MessageModel>> sendMessage({
    required String conversationId,
    required String senderId,
    required String body,
  }) async {
    try {
      final data = await _client
          .from(Tables.messages)
          .insert({'conversation_id': conversationId, 'sender_id': senderId, 'body': body})
          .select()
          .single();
      await _client.from(Tables.conversations).update({
        'last_message': body,
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);
      return Right(MessageModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  RealtimeChannel subscribeToMessages(String conversationId, void Function(MessageModel) onInsert) {
    return _client
        .channel('messages:$conversationId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: Tables.messages,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'conversation_id', value: conversationId),
          callback: (payload) => onInsert(MessageModel.fromJson(payload.newRecord)),
        )
        .subscribe();
  }
}
