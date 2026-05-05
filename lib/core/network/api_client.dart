import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage.dart';
import 'interceptors/app_key_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
import 'package:flutter/foundation.dart';

final apiClientProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: AppConstants.connectTimeoutSeconds),
      receiveTimeout: const Duration(seconds: AppConstants.receiveTimeoutSeconds),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AppKeyInterceptor(secureStorage),
    AuthInterceptor(secureStorage),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ),
  ]);

  return dio;
});