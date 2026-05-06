import 'package:asilov/core/utils/result.dart';
import 'package:asilov/features/templates/domain/entities/template_entity.dart';

abstract class TemplateRepository {
  Future<Result<List<TemplateEntity>>> getTemplates({String? orientation});
  Future<Result<TemplateEntity>> getTemplateDetail(String uuid);
}