import '../../../../core/utils/result.dart';
import '../entities/subscription_status_entity.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionStatusUseCase {
  final SubscriptionRepository _repository;

  GetSubscriptionStatusUseCase(this._repository);

  Future<Result<SubscriptionStatusEntity>> call(String platform) {
    return _repository.getSubscriptionStatus(platform);
  }
}