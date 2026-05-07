import 'package:asilov/features/custom_video/domain/entities/custom_video_request_entity.dart';

class EditRequestModel {
  final int id;
  final String editPrompt;
  final String status;
  final String? adminNote;
  final DateTime createdAt;

  const EditRequestModel({
    required this.id,
    required this.editPrompt,
    required this.status,
    this.adminNote,
    required this.createdAt,
  });

  factory EditRequestModel.fromJson(Map<String, dynamic> json) {
    return EditRequestModel(
      id: json['id'] as int,
      editPrompt: json['edit_prompt'] as String,
      status: json['status'] as String,
      adminNote: json['admin_note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  EditRequestEntity toEntity() {
    return EditRequestEntity(
      id: id,
      editPrompt: editPrompt,
      status: status,
      adminNote: adminNote,
      createdAt: createdAt,
    );
  }
}

class SegmentModel {
  final int id;
  final int segmentNumber;
  final String? videoUrl;
  final String status;
  final int progress;
  final String? failureReason;
  final bool hasPendingEdit;
  final EditRequestModel? latestEditRequest;

  const SegmentModel({
    required this.id,
    required this.segmentNumber,
    this.videoUrl,
    required this.status,
    required this.progress,
    this.failureReason,
    required this.hasPendingEdit,
    this.latestEditRequest,
  });

  factory SegmentModel.fromJson(Map<String, dynamic> json) {
    return SegmentModel(
      id: json['id'] as int,
      segmentNumber: json['segment_number'] as int,
      videoUrl: json['video_url'] as String?,
      status: json['status'] as String,
      progress: json['progress'] as int,
      failureReason: json['failure_reason'] as String?,
      hasPendingEdit: json['has_pending_edit'] as bool? ?? false,
      latestEditRequest: json['latest_edit_request'] != null
          ? EditRequestModel.fromJson(
              json['latest_edit_request'] as Map<String, dynamic>)
          : null,
    );
  }

  SegmentEntity toEntity() {
    return SegmentEntity(
      id: id,
      segmentNumber: segmentNumber,
      videoUrl: videoUrl,
      status: _parseStatus(status),
      progress: progress,
      failureReason: failureReason,
      hasPendingEdit: hasPendingEdit,
      latestEditRequest: latestEditRequest?.toEntity(),
    );
  }

  static CustomVideoStatus _parseStatus(String status) {
    return switch (status) {
      'processing' => CustomVideoStatus.processing,
      'completed'  => CustomVideoStatus.completed,
      'failed'     => CustomVideoStatus.failed,
      _            => CustomVideoStatus.pending,
    };
  }
}

class CustomVideoRequestModel {
  final String uuid;
  final String prompt;
  final String format;
  final String? inputImagePath;
  final String status;
  final int? tokenCost;
  final int overallProgress;
  final int? segmentsCount;
  final int? completedSegments;
  final String? failureReason;
  final DateTime createdAt;
  final List<SegmentModel> segments;

  const CustomVideoRequestModel({
    required this.uuid,
    required this.prompt,
    required this.format,
    this.inputImagePath,
    required this.status,
    this.tokenCost,
    required this.overallProgress,
    this.segmentsCount,
    this.completedSegments,
    this.failureReason,
    required this.createdAt,
    this.segments = const [],
  });

  factory CustomVideoRequestModel.fromJson(Map<String, dynamic> json) {
    final segmentsList = json['segments'] as List<dynamic>?;

    return CustomVideoRequestModel(
      uuid: json['uuid'] as String,
      prompt: json['prompt'] as String,
      format: json['format'] as String? ?? 'vertical',
      inputImagePath: json['input_image_path'] as String?,
      status: json['status'] as String,
      tokenCost: json['token_cost'] as int?,
      overallProgress: json['overall_progress'] as int? ?? 0,
      segmentsCount: json['segments_count'] as int?,
      completedSegments: json['completed_segments'] as int?,
      failureReason: json['failure_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      segments: segmentsList
              ?.map((e) => SegmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  CustomVideoRequestEntity toEntity() {
    return CustomVideoRequestEntity(
      uuid: uuid,
      prompt: prompt,
      format: _parseFormat(format),
      inputImagePath: inputImagePath,
      status: _parseStatus(status),
      tokenCost: tokenCost,
      overallProgress: overallProgress,
      segmentsCount: segmentsCount,
      completedSegments: completedSegments,
      failureReason: failureReason,
      createdAt: createdAt,
      segments: segments.map((s) => s.toEntity()).toList(),
    );
  }

  static CustomVideoStatus _parseStatus(String status) {
    return switch (status) {
      'processing' => CustomVideoStatus.processing,
      'completed'  => CustomVideoStatus.completed,
      'failed'     => CustomVideoStatus.failed,
      _            => CustomVideoStatus.pending,
    };
  }

  static CustomVideoFormat _parseFormat(String format) {
    return switch (format) {
      'horizontal' => CustomVideoFormat.horizontal,
      'square'     => CustomVideoFormat.square,
      _            => CustomVideoFormat.vertical,
    };
  }
}