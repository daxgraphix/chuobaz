import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_providers.dart';
import '../../data/models/app_user_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(supabaseClientProvider));
});

class AuthState {
  final AppUserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({this.user, this.isLoading = false, this.errorMessage});

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  AuthNotifier(this._repository) : super(const AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) => state = AuthState(isLoading: false, errorMessage: failure.message),
      (user) => state = AuthState(user: user, isLoading: false),
    );
    _repository.authStateChanges.listen((isSignedIn) async {
      if (!isSignedIn) {
        state = const AuthState(isLoading: false, clearUser: true);
      }
    });
  }

  Future<bool> signUp(
      {required String email, required String password, required String username}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.signUpWithEmail(
        email: email, password: password, username: username);
    return result.fold((failure) {
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
      return false;
    }, (user) {
      state = AuthState(user: user, isLoading: false);
      return true;
    });
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.signInWithEmail(email: email, password: password);
    return result.fold((failure) {
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
      return false;
    }, (user) {
      state = AuthState(user: user, isLoading: false);
      return true;
    });
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.signInWithGoogle();
    return result.fold((failure) {
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
      return false;
    }, (user) {
      state = AuthState(user: user, isLoading: false);
      return true;
    });
  }

  Future<bool> signInWithApple() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.signInWithApple();
    return result.fold((failure) {
      state = state.copyWith(isLoading: false, errorMessage: failure.message);
      return false;
    }, (user) {
      state = AuthState(user: user, isLoading: false);
      return true;
    });
  }

  Future<bool> sendPasswordReset(String email) async {
    final result = await _repository.sendPasswordResetEmail(email);
    return result.fold((failure) {
      state = state.copyWith(errorMessage: failure.message);
      return false;
    }, (_) => true);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AuthState(isLoading: false, clearUser: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final currentUserProvider = Provider((ref) => ref.watch(authProvider).user);
final isAuthenticatedProvider = Provider((ref) => ref.watch(authProvider).isAuthenticated);
