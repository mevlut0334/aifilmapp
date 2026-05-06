class SliderModel {
  final int id;
  final Map<String, String> title;
  final Map<String, String> description;
  final Map<String, String>? buttonText;
  final String? buttonLink;
  final String imageUrl;
  final int order;

  const SliderModel({
    required this.id,
    required this.title,
    required this.description,
    this.buttonText,
    this.buttonLink,
    required this.imageUrl,
    required this.order,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'] as int,
      title: Map<String, String>.from(json['title'] as Map),
      description: Map<String, String>.from(json['description'] as Map),
      buttonText: json['button_text'] != null
          ? Map<String, String>.from(json['button_text'] as Map)
          : null,
      buttonLink: json['button_link'] as String?,
      imageUrl: json['image_url'] as String,
      order: json['order'] as int,
    );
  }

  String getTitle(String locale) =>
      title[locale] ?? title['en'] ?? '';

  String getDescription(String locale) =>
      description[locale] ?? description['en'] ?? '';

  String? getButtonText(String locale) =>
      buttonText?[locale] ?? buttonText?['en'];
}