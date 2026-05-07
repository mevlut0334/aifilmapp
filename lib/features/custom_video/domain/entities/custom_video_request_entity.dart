enum CustomVideoStatus { pending, processing, completed, failed }

enum CustomVideoFormat { vertical, horizontal, square }

class EditRequestEntity {
  final int id;
  final String editPrompt;
  final String status;
  final String? adminNote;
  final DateTime createdAt;

  const EditRequestEntity({
    required this.id,
    required this.editPrompt,
    required this.status,
    this.adminNote,
    required this.createdAt,
  });
}

class SegmentEntity {
  final int id;
  final int segmentNumber;
  final String? videoUrl;
  final CustomVideoStatus status;
  final int progress;
  final String? failureReason;
  final bool hasPendingEdit;
  final EditRequestEntity? latestEditRequest;

  const SegmentEntity({
    required this.id,
    required this.segmentNumber,
    this.videoUrl,
    required this.status,
    required this.progress,
    this.failureReason,
    required this.hasPendingEdit,
    this.latestEditRequest,
  });

  bool get isCompleted => status == CustomVideoStatus.completed;
  bool get canRequestEdit => isCompleted && !hasPendingEdit;
}

class CustomVideoRequestEntity {
  final String uuid;
  final String prompt;
  final CustomVideoFormat format;
  final String? inputImagePath;
  final CustomVideoStatus status;
  final int? tokenCost;
  final int overallProgress;
  final int? segmentsCount;
  final int? completedSegments;
  final String? failureReason;
  final DateTime createdAt;
  final List<SegmentEntity> segments;

  const CustomVideoRequestEntity({
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

  bool get isCompleted => status == CustomVideoStatus.completed;
  bool get isFailed => status == CustomVideoStatus.failed;
  bool get isInProgress =>
      status == CustomVideoStatus.pending ||
      status == CustomVideoStatus.processing;
}