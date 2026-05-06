import '../../../../core/utils/result.dart';
import '../entities/generation_request_entity.dart';
import '../repositories/generation_repository.dart';

class GetGenerationRequestsUseCase {
  final GenerationRepository _repository;

  const GetGenerationRequestsUseCase(this._repository);

  Future<Result<List<GenerationRequestEntity>>> call() {
    return _repository.getGenerationRequests();
  }
}