// lib/features/generation/domain/entities/generation_request_entity.dart

enum GenerationStatus { pending, processing, completed, failed }

enum GenerationType { templateImage, templateVideo }

class GenerationRequestEntity {
  final String uuid;
  final GenerationType type;
  final String templateId;
  final String? orientation;
  final GenerationStatus status;
  final int progress;
  final int tokenCost;
  final String? outputImageUrl;
  final String? outputVideoUrl;
  final String? failureReason;
  final DateTime createdAt;

  const GenerationRequestEntity({
    required this.uuid,
    required this.type,
    required this.templateId,
    this.orientation,
    required this.status,
    required this.progress,
    required this.tokenCost,
    this.outputImageUrl,
    this.outputVideoUrl,
    this.failureReason,
    required this.createdAt,
  });
}