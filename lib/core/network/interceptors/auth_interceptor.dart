import 'package:dio/dio.dart';
import '../../constants/api_constants.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.headerAuthorization] = 'Bearer $token';
      }
    } catch (_) {
      // Token okunamazsa header'a ekleme, isteği yine de gönder
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      if (err.response?.statusCode == 401) {
        await _secureStorage.deleteToken();
      }
    } catch (_) {
      // Silme başarısız olsa bile hatayı ilet
    }
    handler.next(err);
  }
}