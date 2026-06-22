import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import 'models/report_model.dart';

class ModerationRepository {
  final SupabaseClient _client;
  ModerationRepository(this._client);

  Future<Either<Failure, void>> submitReport({
    required String reporterId,
    required String targetId,
    required String targetType,
    required String reason,
    String? details,
  }) async {
    try {
      await _client.from(Tables.reports).insert({
        'reporter_id': reporterId,
        'target_id': targetId,
        'target_type': targetType,
        'reason': reason,
        'details': details,
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<ReportModel>>> getReports({ReportStatus? status}) async {
    try {
      var query = _client.from(Tables.reports).select('*, reporter:reporter_id ( username )');
      if (status != null) query = query.eq('status', status.name);
      final data = await query.order('created_at', ascending: false);
      return Right((data as List).map((e) => ReportModel.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> resolveReport(String id, ReportStatus status) async {
    try {
      await _client.from(Tables.reports).update({'status': status.name}).eq('id', id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> hideContent(String targetId, String targetType) async {
    try {
      final table = targetType == 'comment' ? Tables.comments : Tables.posts;
      await _client.from(table).update({'is_hidden': true}).eq('id', targetId);
      await _logAudit('hide_content', targetId, targetType);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> lockThread(String postId, bool lock) async {
    try {
      await _client.from(Tables.posts).update({'is_locked': lock}).eq('id', postId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> pinThread(String postId, bool pin) async {
    try {
      await _client.from(Tables.posts).update({'is_pinned': pin}).eq('id', postId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  /// Mutes are tracked purely via audit_logs + a `muted_until` column on
  /// `users` (see supabase/schema.sql). Extend as needed for duration-based
  /// mutes.
  Future<Either<Failure, void>> muteUser(String userId, {required String moderatorId, String? reason}) async {
    try {
      await _client.from(Tables.users).update({
        'muted_until': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      }).eq('id', userId);
      await _logAudit('mute_user', userId, 'user', moderatorId: moderatorId, reason: reason);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _logAudit(String action, String targetId, String targetType, {String? moderatorId, String? reason}) async {
    await _client.from(Tables.auditLogs).insert({
      'actor_id': moderatorId ?? _client.auth.currentUser?.id,
      'action': action,
      'target_id': targetId,
      'target_type': targetType,
      'reason': reason,
    });
  }
}
