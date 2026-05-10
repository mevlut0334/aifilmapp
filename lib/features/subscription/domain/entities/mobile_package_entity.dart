class MobilePackageEntity {
  final int id;
  final String title;
  final String description;
  final int tokenAmount;
  final String iosProductId;
  final String androidProductId;
  final int order;

  const MobilePackageEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.tokenAmount,
    required this.iosProductId,
    required this.androidProductId,
    required this.order,
  });
}