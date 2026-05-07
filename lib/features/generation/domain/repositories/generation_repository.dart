// lib/features/generation/domain/repositories/generation_repository.dart

import '../../../../core/utils/result.dart';
import '../entities/generation_request_entity.dart';

abstract interface class GenerationRepository {
  /// Token bakiyesini getirir.
  Future<Result<int>> getTokenBalance();

  /// Template ile talep oluşturur.
  Future<Result<GenerationRequestEntity>> createTemplateGeneration({
    required GenerationType type,
    required String templateId,
    required String imagePath,
    String? orientation,
  });

  /// Custom görsel talebi oluşturur.
  Future<Result<GenerationRequestEntity>> createCustomImageGeneration({
    required String orientation,
    required String description,
    String? imagePath,
  });

  /// Kullanıcının tüm generation taleplerini listeler.
  Future<Result<List<GenerationRequestEntity>>> getGenerationRequests();
}