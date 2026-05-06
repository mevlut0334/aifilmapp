import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  const AuthRemoteDatasource(this._dio);

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return LoginResponseModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String countryCode,
    required String phone,
  }) async {
    try {
      await _dio.post(
        ApiConstants.register,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'country_code': countryCode,
          'phone': phone,
        },
      );
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return UserModel.fromJson(response.data['data']['user']);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Never _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] as String? ??
        e.message ??
        'Unknown error';

    switch (statusCode) {
      case 401:
        throw UnauthorizedException(message);
      case 404:
        throw NotFoundException(message);
      default:
        throw ServerException(message, statusCode: statusCode);
    }
  }
}