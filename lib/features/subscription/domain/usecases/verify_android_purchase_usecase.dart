import '../../../../core/utils/result.dart';
import '../repositories/subscription_repository.dart';

class VerifyAndroidPurchaseUseCase {
  final SubscriptionRepository _repository;

  VerifyAndroidPurchaseUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String productId,
    required String purchaseToken,
    required String packageName,
  }) {
    return _repository.verifyAndroidPurchase(
      productId: productId,
      purchaseToken: purchaseToken,
      packageName: packageName,
    );
  }
}