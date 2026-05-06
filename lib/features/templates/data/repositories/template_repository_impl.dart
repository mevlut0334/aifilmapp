import 'package:asilov/core/error/exceptions.dart';
import 'package:asilov/core/utils/result.dart';
import 'package:asilov/features/templates/data/datasources/template_remote_datasource.dart';
import 'package:asilov/features/templates/domain/entities/template_entity.dart';
import 'package:asilov/features/templates/domain/repositories/template_repository.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateRemoteDataSource _dataSource;

  const TemplateRepositoryImpl(this._dataSource);

  @override
  Future<Result<List<TemplateEntity>>> getTemplates({String? orientation}) async {
    try {
      final models = await _dataSource.getTemplates(orientation: orientation);
      return Success(models.map((e) => e.toEntity()).toList());
    } on UnauthorizedException catch (e) {
      return Failure(e.message, statusCode: 401);
    } on NetworkException catch (e) {
      return Failure(e.message);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return const Failure('Beklenmeyen bir hata oluştu');
    }
  }

  @override
  Future<Result<TemplateEntity>> getTemplateDetail(String uuid) async {
    try {
      final model = await _dataSource.getTemplateDetail(uuid);
      return Success(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Failure(e.message, statusCode: 401);
    } on NotFoundException catch (e) {
      return Failure(e.message, statusCode: 404);
    } on NetworkException catch (e) {
      return Failure(e.message);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return const Failure('Beklenmeyen bir hata oluştu');
    }
  }
}