import 'package:asilov/features/templates/domain/entities/template_entity.dart';

class LocalizedTextModel {
  final String en;
  final String tr;

  const LocalizedTextModel({required this.en, required this.tr});

  factory LocalizedTextModel.fromJson(Map<String, dynamic> json) {
    return LocalizedTextModel(
      en: json['en'] as String? ?? '',
      tr: json['tr'] as String? ?? '',
    );
  }

  // ✅ FIX: description alanı [], null veya {} gelebilir — güvenli parse
  factory LocalizedTextModel.fromJsonOrEmpty(dynamic json) {
    if (json is Map<String, dynamic>) {
      return LocalizedTextModel(
        en: json['en'] as String? ?? '',
        tr: json['tr'] as String? ?? '',
      );
    }
    return const LocalizedTextModel(en: '', tr: '');
  }

  LocalizedText toEntity() => LocalizedText(en: en, tr: tr);
}

class TemplateModel {
  final String uuid;
  final LocalizedTextModel title;
  final LocalizedTextModel description;
  final int tokenCost;
  final String? landscapeVideoUrl;
  final String? portraitVideoUrl;
  final String? squareVideoUrl;
  final String? posterUrl;
  final DateTime createdAt;

  const TemplateModel({
    required this.uuid,
    required this.title,
    required this.description,
    required this.tokenCost,
    this.landscapeVideoUrl,
    this.portraitVideoUrl,
    this.squareVideoUrl,
    this.posterUrl,
    required this.createdAt,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    return TemplateModel(
      uuid: json['uuid'] as String,
      title: LocalizedTextModel.fromJson(json['title'] as Map<String, dynamic>),
      // ✅ FIX: description için güvenli parse — [], null, {} hepsini handle eder
      description: LocalizedTextModel.fromJsonOrEmpty(json['description']),
      tokenCost: (json['token_cost'] as num).toInt(),
      landscapeVideoUrl: json['landscape_video_url'] as String?,
      portraitVideoUrl: json['portrait_video_url'] as String?,
      squareVideoUrl: json['square_video_url'] as String?,
      posterUrl: json['poster_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  TemplateEntity toEntity() {
    return TemplateEntity(
      uuid: uuid,
      title: title.toEntity(),
      description: description.toEntity(),
      tokenCost: tokenCost,
      landscapeVideoUrl: landscapeVideoUrl,
      portraitVideoUrl: portraitVideoUrl,
      squareVideoUrl: squareVideoUrl,
      posterUrl: posterUrl,
      createdAt: createdAt,
    );
  }
}