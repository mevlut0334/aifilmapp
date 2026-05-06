// lib/features/generation/domain/usecases/create_template_generation_usecase.dart

import '../../../../core/utils/result.dart';
import '../entities/generation_request_entity.dart';
import '../repositories/generation_repository.dart';

class CreateTemplateGenerationUseCase {
  final GenerationRepository _repository;

  const CreateTemplateGenerationUseCase(this._repository);

  /// Token kontrolü yaparak talep oluşturur.
  /// [tokenCost]  → template'in maliyeti (UI'dan gelir)
  /// [balance]    → mevcut bakiye (UI'dan gelir)
  /// Yeterli bakiye yoksa Failure döner, API'ye istek atmaz.
  Future<Result<GenerationRequestEntity>> call({
    required GenerationType type,
    required String templateId,
    required String imagePath,
    required int tokenCost,
    required int balance,
    String? orientation,
  }) async {
    if (balance < tokenCost) {
      return const Failure(
        'Insufficient tokens',
        statusCode: 402,
      );
    }

    return _repository.createTemplateGeneration(
      type: type,
      templateId: templateId,
      imagePath: imagePath,
      orientation: orientation,
    );
  }
}