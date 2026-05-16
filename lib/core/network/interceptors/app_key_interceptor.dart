import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';

class AppKeyInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AppKeyInterceptor(this._secureStorage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers[ApiConstants.headerAppKey] = ApiConstants.appKey;
    options.headers[ApiConstants.headerSecretKey] = ApiConstants.secretKey;

    final locale = await _secureStorage.getLocale();
    final deviceLocale = ui.PlatformDispatcher.instance.locale.languageCode;
    final resolved = AppConstants.supportedLocales.contains(deviceLocale)
        ? deviceLocale
        : AppConstants.defaultLocale;

    options.headers[ApiConstants.headerAcceptLanguage] = locale ?? resolved;

    handler.next(options);
  }
}