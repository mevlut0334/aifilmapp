import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/mobile_package_model.dart';

abstract class SubscriptionRemoteDatasource {
  Future<List<MobilePackageModel>> getMobilePackages(String platform);
  Future<Map<String, dynamic>> verifyIosPurchase({
    required String productId,
    required String receiptData,
  });
  Future<Map<String, dynamic>> verifyAndroidPurchase({
    required String productId,
    required String purchaseToken,
    required String packageName,
  });
  Future<Map<String, dynamic>> getSubscriptionStatus(String platform);
}

class SubscriptionRemoteDatasourceImpl implements SubscriptionRemoteDatasource {
  final Dio _dio;

  SubscriptionRemoteDatasourceImpl(this._dio);

  @override
  Future<List<MobilePackageModel>> getMobilePackages(String platform) async {
    try {
      final response = await _dio.get(
        ApiConstants.mobilePackages,
        queryParameters: {'platform': platform},
      );
      final data = response.data['data'] as List;
      return data.map((e) => MobilePackageModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to get packages',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> verifyIosPurchase({
    required String productId,
    required String receiptData,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.iosSubscribe,
        data: {
          'product_id': productId,
          'receipt_data': receiptData,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'iOS purchase verification failed',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> verifyAndroidPurchase({
    required String productId,
    required String purchaseToken,
    required String packageName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.androidSubscribe,
        data: {
          'product_id': productId,
          'purchase_token': purchaseToken,
          'package_name': packageName,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Android purchase verification failed',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getSubscriptionStatus(String platform) async {
    try {
      final response = await _dio.get(
        ApiConstants.subscriptionStatus,
        queryParameters: {'platform': platform},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(
        e.response?.data['message'] ?? 'Failed to get subscription status',
      );
    }
  }
}