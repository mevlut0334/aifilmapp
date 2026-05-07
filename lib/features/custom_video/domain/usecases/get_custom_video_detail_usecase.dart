import 'package:asilov/core/utils/result.dart';
import 'package:asilov/features/custom_video/domain/entities/custom_video_request_entity.dart';
import 'package:asilov/features/custom_video/domain/repositories/custom_video_repository.dart';

class GetCustomVideoDetailUsecase {
  final CustomVideoRepository _repository;

  GetCustomVideoDetailUsecase(this._repository);

  Future<Result<CustomVideoRequestEntity>> call(String uuid) {
    return _repository.getCustomVideoDetail(uuid);
  }
}