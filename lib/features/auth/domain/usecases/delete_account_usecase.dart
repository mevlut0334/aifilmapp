import '../../../../core/utils/result.dart';
import '../repositories/auth_repository.dart';

class DeleteAccountUseCase {
  final AuthRepository _repository;

  const DeleteAccountUseCase(this._repository);

  Future<Result<void>> call() {
    return _repository.deleteAccount();
  }
}