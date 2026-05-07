import 'package:asilov/core/utils/result.dart';
import 'package:asilov/features/custom_video/domain/entities/custom_video_request_entity.dart';
import 'package:asilov/features/custom_video/domain/repositories/custom_video_repository.dart';

class GetCustomVideoRequestsUsecase {
  final CustomVideoRepository _repository;

  GetCustomVideoRequestsUsecase(this._repository);

  Future<Result<List<CustomVideoRequestEntity>>> call() {
    return _repository.getCustomVideoRequests();
  }
}