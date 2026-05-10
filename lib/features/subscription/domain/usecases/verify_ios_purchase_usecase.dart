import '../../../../core/utils/result.dart';
import '../repositories/subscription_repository.dart';

class VerifyIosPurchaseUseCase {
  final SubscriptionRepository _repository;

  VerifyIosPurchaseUseCase(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    required String productId,
    required String receiptData,
  }) {
    return _repository.verifyIosPurchase(
      productId: productId,
      receiptData: receiptData,
    );
  }
}