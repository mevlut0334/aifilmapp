import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/custom_video_request_model.dart';

class CustomVideoRemoteDatasource {
  final Dio _dio;

  const CustomVideoRemoteDatasource(this._dio);

  // ─── Talep Oluştur ────────────────────────────────────────────────────────

  Future<CustomVideoRequestModel> createCustomVideoRequest({
    required String prompt,
    required String format,
    File? inputImage,
  }) async {
    final map = <String, dynamic>{
      'prompt': prompt,
      'format': format,
    };

    if (inputImage != null) {
      map['input_image'] = await MultipartFile.fromFile(
        inputImage.path,
        filename: inputImage.uri.pathSegments.last,
      );
    }

    final response = await _dio.post(
      ApiConstants.customVideoRequests,
      data: FormData.fromMap(map),
    );

    final requestJson =
        response.data['data']['request'] as Map<String, dynamic>;
    return CustomVideoRequestModel.fromJson(requestJson);
  }

  // ─── Talep Listesi ────────────────────────────────────────────────────────

  Future<List<CustomVideoRequestModel>> getCustomVideoRequests() async {
    final response = await _dio.get(ApiConstants.customVideoRequests);
    final list = response.data['data']['requests'] as List<dynamic>;
    return list
        .map((e) => CustomVideoRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Talep Detayı ─────────────────────────────────────────────────────────

  Future<CustomVideoRequestModel> getCustomVideoDetail(String uuid) async {
    final response = await _dio.get(
      ApiConstants.customVideoDetail(uuid),
    );
    final requestJson =
        response.data['data']['request'] as Map<String, dynamic>;
    return CustomVideoRequestModel.fromJson(requestJson);
  }

  // ─── Segment Düzenleme Talebi ─────────────────────────────────────────────

  Future<void> editSegment({
    required String uuid,
    required int segmentId,
    required String editPrompt,
  }) async {
    await _dio.post(
      ApiConstants.segmentEdit(uuid, segmentId),
      data: {'edit_prompt': editPrompt},
    );
  }
}