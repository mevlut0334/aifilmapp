import 'package:asilov/core/utils/result.dart';
import 'package:asilov/features/templates/domain/entities/template_entity.dart';
import 'package:asilov/features/templates/domain/repositories/template_repository.dart';

class GetTemplatesUseCase {
  final TemplateRepository _repository;

  const GetTemplatesUseCase(this._repository);

  Future<Result<List<TemplateEntity>>> call({String? orientation}) {
    return _repository.getTemplates(orientation: orientation);
  }
}