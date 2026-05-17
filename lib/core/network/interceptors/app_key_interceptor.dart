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
    try {
      options.headers[ApiConstants.headerAppKey] = ApiConstants.appKey;
      options.headers[ApiConstants.headerSecretKey] = ApiConstants.secretKey;

      final deviceLocale = ui.PlatformDispatcher.instance.locale.languageCode;
      final resolved = AppConstants.supportedLocales.contains(deviceLocale)
          ? deviceLocale
          : AppConstants.defaultLocale;

      String? locale;
      try {
        locale = await _secureStorage.getLocale();
      } catch (_) {
        // Locale okunamazsa cihaz dilini kullan
      }

      options.headers[ApiConstants.headerAcceptLanguage] = locale ?? resolved;
    } catch (_) {
      // Header eklenemezse isteği yine de gönder
    }
    handler.next(options);
  }
}