import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/app_user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;
  AuthRepositoryImpl(this._client);

  @override
  Future<Either<Failure, AppUserModel>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      if (res.user == null) {
        return const Left(AuthFailure('Sign up failed. Please try again.'));
      }
      // The `users` row is auto-created by a Postgres trigger
      // (handle_new_user) defined in supabase/schema.sql, populated from
      // raw_user_meta_data.username. We fetch it back here.
      final profile = await _client
          .from(Tables.users)
          .select()
          .eq('id', res.user!.id)
          .maybeSingle();
      if (profile == null) {
        return Right(AppUserModel(
          id: res.user!.id,
          email: email,
          username: username,
          createdAt: DateTime.now(),
        ));
      }
      return Right(AppUserModel.fromJson(profile));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUserModel>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final res =
          await _client.auth.signInWithPassword(email: email, password: password);
      if (res.user == null) {
        return const Left(AuthFailure('Invalid email or password.'));
      }
      final profile = await _client
          .from(Tables.users)
          .select()
          .eq('id', res.user!.id)
          .single();
      return Right(AppUserModel.fromJson(profile));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUserModel>> signInWithGoogle() async {
    try {
      // Requires the Google provider to be configured in
      // Supabase Dashboard -> Authentication -> Providers, plus the
      // matching OAuth client ID registered for Android/iOS.
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.chuobaz.app://login-callback',
      );
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Google sign-in was cancelled.'));
      }
      final profile =
          await _client.from(Tables.users).select().eq('id', user.id).single();
      return Right(AppUserModel.fromJson(profile));
    } catch (e) {
      return Left(AuthFailure('Google sign-in failed: $e'));
    }
  }

  @override
  Future<Either<Failure, AppUserModel>> signInWithApple() async {
    try {
      // Requires the Apple provider configured in Supabase + Sign in with
      // Apple capability enabled in Xcode for the iOS target.
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.chuobaz.app://login-callback',
      );
      final user = _client.auth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Apple sign-in was cancelled.'));
      }
      final profile =
          await _client.from(Tables.users).select().eq('id', user.id).single();
      return Right(AppUserModel.fromJson(profile));
    } catch (e) {
      return Left(AuthFailure('Apple sign-in failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationEmail() async {
    try {
      final email = _client.auth.currentUser?.email;
      if (email == null) return const Left(AuthFailure('No user signed in.'));
      await _client.auth.resend(type: OtpType.signup, email: email);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppUserModel?>> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return const Right(null);
      final profile =
          await _client.from(Tables.users).select().eq('id', user.id).maybeSingle();
      if (profile == null) return const Right(null);
      return Right(AppUserModel.fromJson(profile));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<bool> get authStateChanges =>
      _client.auth.onAuthStateChange.map((s) => s.session != null);
}
