// lib/features/auth/domain/usecases/reset_password_usecase.dart

import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository _repository;

  const ResetPasswordUseCase(this._repository);

  Future<Result<void>> call({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _repository.resetPassword(
      token: token,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
  }
}