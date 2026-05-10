import '../../../../core/utils/result.dart';
import '../entities/mobile_package_entity.dart';
import '../repositories/subscription_repository.dart';

class GetMobilePackagesUseCase {
  final SubscriptionRepository _repository;

  GetMobilePackagesUseCase(this._repository);

  Future<Result<List<MobilePackageEntity>>> call(String platform) {
    return _repository.getMobilePackages(platform);
  }
}