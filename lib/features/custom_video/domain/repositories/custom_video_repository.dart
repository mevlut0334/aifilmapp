import 'dart:io';

import 'package:asilov/core/utils/result.dart';
import 'package:asilov/features/custom_video/domain/entities/custom_video_request_entity.dart';

abstract class CustomVideoRepository {
  Future<Result<CustomVideoRequestEntity>> createCustomVideoRequest({
    required String prompt,
    required CustomVideoFormat format,
    File? inputImage,
  });

  Future<Result<List<CustomVideoRequestEntity>>> getCustomVideoRequests();

  Future<Result<CustomVideoRequestEntity>> getCustomVideoDetail(String uuid);

  Future<Result<void>> editSegment({
    required String uuid,
    required int segmentId,
    required String editPrompt,
  });
}