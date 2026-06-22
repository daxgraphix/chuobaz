import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failure.dart';
import '../../auth/data/models/app_user_model.dart';

class AdminRepository {
  final SupabaseClient _client;
  AdminRepository(this._client);

  Future<Either<Failure, List<AppUserModel>>> getUsers({String? search, UserRole? role}) async {
    try {
      var query = _client.from(Tables.users).select();
      if (search != null && search.isNotEmpty) query = query.ilike('username', '%$search%');
      if (role != null) query = query.eq('role', role.value);
      final data = await query.order('created_at', ascending: false).limit(100);
      return Right((data as List).map((e) => AppUserModel.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> setUserRole(String userId, UserRole role) async {
    try {
      await _client.from(Tables.users).update({'role': role.value}).eq('id', userId);
      if (role.canModerate) {
        await _client.from(Tables.moderators).upsert({'user_id': userId}, onConflict: 'user_id');
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> verifyUser(String userId, bool verified) async {
    try {
      await _client.from(Tables.users).update({'is_verified': verified}).eq('id', userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> suspendUser(String userId) async {
    try {
      await _client.from(Tables.users).update({
        'muted_until': DateTime.now().add(const Duration(days: 3650)).toIso8601String(),
      }).eq('id', userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
