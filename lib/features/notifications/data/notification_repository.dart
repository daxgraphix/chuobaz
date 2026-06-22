import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import 'models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _client;
  NotificationRepository(this._client);

  Future<Either<Failure, List<AppNotificationModel>>> getNotifications(String userId) async {
    try {
      final data = await _client
          .from(Tables.notifications)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);
      return Right((data as List).map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> markRead(String id) async {
    try {
      await _client.from(Tables.notifications).update({'is_read': true}).eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> markAllRead(String userId) async {
    try {
      await _client.from(Tables.notifications).update({'is_read': true}).eq('user_id', userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Subscribes to realtime INSERTs on the notifications table for [userId].
  RealtimeChannel subscribe(String userId, void Function(AppNotificationModel) onInsert) {
    final channel = _client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: Tables.notifications,
          filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'user_id', value: userId),
          callback: (payload) => onInsert(AppNotificationModel.fromJson(payload.newRecord)),
        )
        .subscribe();
    return channel;
  }
}
