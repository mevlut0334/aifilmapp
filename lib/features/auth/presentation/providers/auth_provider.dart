// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';

// ─── Infrastructure Providers ────────────────────────────────────────────────

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final dio = ref.read(apiClientProvider);
  return AuthRemoteDatasource(dio);
});

final authRepositoryProvider = Provider<AuthRepositoryImpl>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDatasourceProvider),
    ref.read(secureStorageProvider),
  );
});

// ─── UseCase Providers ───────────────────────────────────────────────────────

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  return ForgotPasswordUseCase(ref.read(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.read(authRepositoryProvider));
});

// ─── Auth State ──────────────────────────────────────────────────────────────

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── Auth Notifier ───────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> checkAuthStatus() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.getToken();

    if (token != null && token.isNotEmpty) {
      try {
        final user = await ref
            .read(authRemoteDatasourceProvider)
            .getProfile()
            .then((m) => m.toEntity());
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } catch (_) {
        // Token geçersiz veya süresi dolmuş → temizle
        await storage.deleteToken();
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref
        .read(loginUseCaseProvider)
        .call(email: email, password: password);

    switch (result) {
      case Success<UserEntity>():
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.data,
          isLoading: false,
        );
        return true;

      case Failure<UserEntity>():
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: result.message,
          isLoading: false,
          clearUser: true,
        );
        return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String countryCode,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(registerUseCaseProvider).call(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
          countryCode: countryCode,
          phone: phone,
        );

    switch (result) {
      case Success<UserEntity>():
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: result.data,
          isLoading: false,
        );
        return true;

      case Failure<UserEntity>():
        state = state.copyWith(
          errorMessage: result.message,
          isLoading: false,
        );
        return false;
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref
        .read(forgotPasswordUseCaseProvider)
        .call(email: email);

    switch (result) {
      case Success<void>():
        state = state.copyWith(isLoading: false);
        return true;

      case Failure<void>():
        state = state.copyWith(
          errorMessage: result.message,
          isLoading: false,
        );
        return false;
    }
  }

  Future<bool> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await ref.read(resetPasswordUseCaseProvider).call(
          token: token,
          email: email,
          password: password,
          passwordConfirmation: passwordConfirmation,
        );

    switch (result) {
      case Success<void>():
        state = state.copyWith(isLoading: false);
        return true;

      case Failure<void>():
        state = state.copyWith(
          errorMessage: result.message,
          isLoading: false,
        );
        return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await ref.read(logoutUseCaseProvider).call();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ─── Auth Provider ───────────────────────────────────────────────────────────

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});