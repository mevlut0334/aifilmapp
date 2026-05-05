// lib/features/auth/domain/usecases/forgot_password_usecase.dart

import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  const ForgotPasswordUseCase(this._repository);

  Future<Result<void>> call({required String email}) {
    return _repository.forgotPassword(email: email);
  }
}