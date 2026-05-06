// lib/core/jobs/job_model.dart

enum JobStatus { pending, running, completed, failed }

enum JobType { templateImage, templateVideo, customImage, customVideo }

class UploadJob {
  final String id;           // uuid ile üretilir
  final JobType type;
  final JobStatus status;
  final String? templateId;  // template_image / template_video için
  final String? orientation; // landscape | portrait | square
  final String? description; // custom_image için
  final String? prompt;      // custom_video için
  final String imagePath;    // Seçilen görselin yerel yolu
  final int createdAt;       // millisecondsSinceEpoch
  final String? errorMessage;

  const UploadJob({
    required this.id,
    required this.type,
    required this.status,
    this.templateId,
    this.orientation,
    this.description,
    this.prompt,
    required this.imagePath,
    required this.createdAt,
    this.errorMessage,
  });

  UploadJob copyWith({
    JobStatus? status,
    String? errorMessage,
  }) {
    return UploadJob(
      id: id,
      type: type,
      status: status ?? this.status,
      templateId: templateId,
      orientation: orientation,
      description: description,
      prompt: prompt,
      imagePath: imagePath,
      createdAt: createdAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'status': status.name,
        'templateId': templateId,
        'orientation': orientation,
        'description': description,
        'prompt': prompt,
        'imagePath': imagePath,
        'createdAt': createdAt,
        'errorMessage': errorMessage,
      };

  factory UploadJob.fromJson(Map<String, dynamic> json) => UploadJob(
        id: json['id'] as String,
        type: JobType.values.byName(json['type'] as String),
        status: JobStatus.values.byName(json['status'] as String),
        templateId: json['templateId'] as String?,
        orientation: json['orientation'] as String?,
        description: json['description'] as String?,
        prompt: json['prompt'] as String?,
        imagePath: json['imagePath'] as String,
        createdAt: json['createdAt'] as int,
        errorMessage: json['errorMessage'] as String?,
      );
}