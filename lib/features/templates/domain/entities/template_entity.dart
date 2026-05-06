class LocalizedText {
  final String en;
  final String tr;

  const LocalizedText({
    required this.en,
    required this.tr,
  });

  String localized(String languageCode) {
    return languageCode == 'tr' ? tr : en;
  }
}

class TemplateEntity {
  final String uuid;
  final LocalizedText title;
  final LocalizedText description;
  final int tokenCost;
  final String? landscapeVideoUrl;
  final String? portraitVideoUrl;
  final String? squareVideoUrl;
  final String? posterUrl;
  final DateTime createdAt;

  const TemplateEntity({
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

  String? videoUrlFor(String orientation) {
    return switch (orientation) {
      'landscape' => landscapeVideoUrl,
      'portrait' => portraitVideoUrl,
      'square' => squareVideoUrl,
      _ => portraitVideoUrl,
    };
  }
}