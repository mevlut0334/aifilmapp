import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/mobile_package_entity.dart';
import '../../domain/entities/subscription_status_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDatasource _datasource;

  SubscriptionRepositoryImpl(this._datasource);

  @override
  Future<Result<List<MobilePackageEntity>>> getMobilePackages(
      String platform) async {
    try {
      final packages = await _datasource.getMobilePackages(platform);
      return Success(packages);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> verifyIosPurchase({
    required String productId,
    required String receiptData,
  }) async {
    try {
      final result = await _datasource.verifyIosPurchase(
        productId: productId,
        receiptData: receiptData,
      );
      return Success(result);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> verifyAndroidPurchase({
    required String productId,
    required String purchaseToken,
    required String packageName,
  }) async {
    try {
      final result = await _datasource.verifyAndroidPurchase(
        productId: productId,
        purchaseToken: purchaseToken,
        packageName: packageName,
      );
      return Success(result);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<SubscriptionStatusEntity>> getSubscriptionStatus(
      String platform) async {
    try {
      final data = await _datasource.getSubscriptionStatus(platform);
      final entity = SubscriptionStatusEntity(
        isActive: data['is_active'] as bool,
        platform: data['platform'] as String,
        autoRenewing: data['auto_renewing'] as bool,
        status: data['status'] as String,
        expiresAt: data['expires_at'] != null
            ? DateTime.parse(data['expires_at'] as String)
            : null,
        packageId: data['package_id'] as int?,
        tokenAmount: data['token_amount'] as int?,
      );
      return Success(entity);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}