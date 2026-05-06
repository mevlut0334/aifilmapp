// lib/features/generation/data/datasources/generation_remote_datasource.dart

import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/generation_request_model.dart';

class GenerationRemoteDatasource {
  final Dio _dio;

  const GenerationRemoteDatasource(this._dio);

  // ─── Token Bakiyesi ───────────────────────────────────────────────────────

  Future<int> getTokenBalance() async {
    final response = await _dio.get('/tokens/balance');
    final data = response.data['data'] as Map<String, dynamic>;
    return data['balance'] as int;
  }

  // ─── Talep Oluştur ────────────────────────────────────────────────────────

  Future<GenerationRequestModel> createTemplateGeneration({
    required String type,
    required String templateId,
    required String imagePath,
    String? orientation,
  }) async {
    final imageFile = File(imagePath);

    final formData = FormData.fromMap({
      'type': type,
      'template_id': templateId,
      'input_image': await MultipartFile.fromFile(
        imagePath,
        filename: imageFile.uri.pathSegments.last,
      ),
      if (orientation != null) 'orientation': orientation,
    });

    final response = await _dio.post(
      ApiConstants.generationRequests,
      data: formData,
    );

    final requestJson =
        response.data['data']['request'] as Map<String, dynamic>;
    return GenerationRequestModel.fromJson(requestJson);
  }

  // ─── Talep Listesi ────────────────────────────────────────────────────────

  Future<List<GenerationRequestModel>> getGenerationRequests() async {
    final response = await _dio.get(ApiConstants.generationRequests);
    final list = response.data['data']['requests'] as List<dynamic>;
    return list
        .map((e) =>
            GenerationRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}