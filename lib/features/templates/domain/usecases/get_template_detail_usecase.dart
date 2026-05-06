import 'package:asilov/core/utils/result.dart';
import 'package:asilov/features/templates/domain/entities/template_entity.dart';
import 'package:asilov/features/templates/domain/repositories/template_repository.dart';

class GetTemplateDetailUseCase {
  final TemplateRepository _repository;

  const GetTemplateDetailUseCase(this._repository);

  Future<Result<TemplateEntity>> call(String uuid) {
    return _repository.getTemplateDetail(uuid);
  }
}