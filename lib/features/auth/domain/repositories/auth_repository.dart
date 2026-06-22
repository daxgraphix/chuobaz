import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../data/models/app_user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, AppUserModel>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  });

  Future<Either<Failure, AppUserModel>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUserModel>> signInWithGoogle();

  Future<Either<Failure, AppUserModel>> signInWithApple();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, void>> resendVerificationEmail();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, AppUserModel?>> getCurrentUser();

  Stream<bool> get authStateChanges;
}
