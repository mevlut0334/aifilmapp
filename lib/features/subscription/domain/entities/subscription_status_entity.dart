class SubscriptionStatusEntity {
  final bool isActive;
  final String platform;
  final DateTime? expiresAt;
  final bool autoRenewing;
  final String status;
  final int? packageId;
  final int? tokenAmount;

  const SubscriptionStatusEntity({
    required this.isActive,
    required this.platform,
    required this.autoRenewing,
    required this.status,
    this.expiresAt,
    this.packageId,
    this.tokenAmount,
  });
}