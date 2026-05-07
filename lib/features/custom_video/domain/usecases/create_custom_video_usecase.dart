import 'dart:io';

import 'package:asilov/core/utils/result.dart';
import 'package:asilov/features/custom_video/domain/entities/custom_video_request_entity.dart';
import 'package:asilov/features/custom_video/domain/repositories/custom_video_repository.dart';

class CreateCustomVideoUsecase {
  final CustomVideoRepository _repository;

  CreateCustomVideoUsecase(this._repository);

  Future<Result<CustomVideoRequestEntity>> call({
    required String prompt,
    required CustomVideoFormat format,
    File? inputImage,
  }) {
    return _repository.createCustomVideoRequest(
      prompt: prompt,
      format: format,
      inputImage: inputImage,
    );
  }
}