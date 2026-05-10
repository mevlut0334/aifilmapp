import '../../domain/entities/mobile_package_entity.dart';

class MobilePackageModel extends MobilePackageEntity {
  const MobilePackageModel({
    required super.id,
    required super.title,
    required super.description,
    required super.tokenAmount,
    required super.iosProductId,
    required super.androidProductId,
    required super.order,
  });

  factory MobilePackageModel.fromJson(Map<String, dynamic> json) {
    return MobilePackageModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      tokenAmount: json['token_amount'] as int,
      iosProductId: json['ios_product_id'] as String,
      androidProductId: json['android_product_id'] as String,
      order: json['order'] as int,
    );
  }
}