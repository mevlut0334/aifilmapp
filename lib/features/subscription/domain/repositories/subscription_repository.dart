import '../entities/mobile_package_entity.dart';
import '../entities/subscription_status_entity.dart';
import '../../../../core/utils/result.dart';

abstract class SubscriptionRepository {
  Future<Result<List<MobilePackageEntity>>> getMobilePackages(String platform);

  Future<Result<Map<String, dynamic>>> verifyIosPurchase({
    required String productId,
    required String receiptData,
  });

  Future<Result<Map<String, dynamic>>> verifyAndroidPurchase({
    required String productId,
    required String purchaseToken,
    required String packageName,
  });

  Future<Result<SubscriptionStatusEntity>> getSubscriptionStatus(String platform);
}