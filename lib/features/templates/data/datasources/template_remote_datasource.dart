import 'package:dio/dio.dart';
import 'package:asilov/core/error/exceptions.dart';
import 'package:asilov/features/templates/data/models/template_model.dart';

abstract class TemplateRemoteDataSource {
  Future<List<TemplateModel>> getTemplates({String? orientation});
  Future<TemplateModel> getTemplateDetail(String uuid);
}

class TemplateRemoteDataSourceImpl implements TemplateRemoteDataSource {
  final Dio _dio;

  const TemplateRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TemplateModel>> getTemplates({String? orientation}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (orientation != null) queryParams['orientation'] = orientation;

      final response = await _dio.get(
        '/templates',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;

      if (data['success'] == true) {
        final list = data['data'] as List<dynamic>;
        return list
            .map((e) => TemplateModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ServerException(
        data['message'] as String? ?? 'Bilinmeyen hata',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data['message'] as String? ?? 'Yetkisiz erişim',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('İnternet bağlantısı kurulamadı');
      }
      throw ServerException(
        e.response?.data['message'] as String? ?? 'Sunucu hatası',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<TemplateModel> getTemplateDetail(String uuid) async {
    try {
      final response = await _dio.get('/templates/$uuid');
      final data = response.data;

      if (data['success'] == true) {
        return TemplateModel.fromJson(
          data['data']['template'] as Map<String, dynamic>,
        );
      }

      throw ServerException(
        data['message'] as String? ?? 'Bilinmeyen hata',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException(
          e.response?.data['message'] as String? ?? 'Yetkisiz erişim',
        );
      }
      if (e.response?.statusCode == 404) {
        throw const NotFoundException('Template bulunamadı');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('İnternet bağlantısı kurulamadı');
      }
      throw ServerException(
        e.response?.data['message'] as String? ?? 'Sunucu hatası',
        statusCode: e.response?.statusCode,
      );
    }
  }
}