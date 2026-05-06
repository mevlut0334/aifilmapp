// lib/features/generation/data/models/generation_request_model.dart

import '../../domain/entities/generation_request_entity.dart';

class GenerationRequestModel {
  final String uuid;
  final String type;
  final String templateId;
  final String? orientation;
  final String status;
  final int progress;
  final int tokenCost;
  final String? outputImageUrl;
  final String? outputVideoUrl;
  final String? failureReason;
  final DateTime createdAt;

  const GenerationRequestModel({
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

  factory GenerationRequestModel.fromJson(Map<String, dynamic> json) {
    // API: "template": { "uuid": "...", "title": "...", "token_cost": 50 }
    final templateMap = json['template'] as Map<String, dynamic>?;
    final templateId = templateMap?['uuid'] as String? ?? '';

    // API: tek "output_url" alanı var; type'a göre doğru alana atanır
    final outputUrl = json['output_url'] as String?;
    final type = json['type'] as String;
    final isVideo = type == 'template_video';

    return GenerationRequestModel(
      uuid: json['uuid'] as String,
      type: type,
      templateId: templateId,
      orientation: json['orientation'] as String?,
      status: json['status'] as String,
      progress: json['progress'] as int? ?? 0,
      tokenCost: json['token_cost'] as int,
      outputImageUrl: isVideo ? null : outputUrl,
      outputVideoUrl: isVideo ? outputUrl : null,
      failureReason: json['failure_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  GenerationRequestEntity toEntity() {
    return GenerationRequestEntity(
      uuid: uuid,
      type: _parseType(type),
      templateId: templateId,
      orientation: orientation,
      status: _parseStatus(status),
      progress: progress,
      tokenCost: tokenCost,
      outputImageUrl: outputImageUrl,
      outputVideoUrl: outputVideoUrl,
      failureReason: failureReason,
      createdAt: createdAt,
    );
  }

  static GenerationType _parseType(String type) {
    return switch (type) {
      'template_video' => GenerationType.templateVideo,
      _ => GenerationType.templateImage,
    };
  }

  static GenerationStatus _parseStatus(String status) {
    return switch (status) {
      'processing' => GenerationStatus.processing,
      'completed' => GenerationStatus.completed,
      'failed' => GenerationStatus.failed,
      _ => GenerationStatus.pending,
    };
  }
}