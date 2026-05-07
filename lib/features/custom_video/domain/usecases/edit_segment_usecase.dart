import 'package:asilov/core/utils/result.dart';
import 'package:asilov/features/custom_video/domain/repositories/custom_video_repository.dart';

class EditSegmentUsecase {
  final CustomVideoRepository _repository;

  EditSegmentUsecase(this._repository);

  Future<Result<void>> call({
    required String uuid,
    required int segmentId,
    required String editPrompt,
  }) {
    return _repository.editSegment(
      uuid: uuid,
      segmentId: segmentId,
      editPrompt: editPrompt,
    );
  }
}