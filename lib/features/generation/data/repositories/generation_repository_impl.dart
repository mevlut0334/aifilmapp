// lib/features/generation/data/repositories/generation_repository_impl.dart

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/generation_request_entity.dart';
import '../../domain/repositories/generation_repository.dart';
import '../datasources/generation_remote_datasource.dart';

class GenerationRepositoryImpl implements GenerationRepository {
  final GenerationRemoteDatasource _datasource;

  const GenerationRepositoryImpl(this._datasource);

  // ─── Token Bakiyesi ───────────────────────────────────────────────────────

  @override
  Future<Result<int>> getTokenBalance() async {
    try {
      final balance = await _datasource.getTokenBalance();
      return Success(balance);
    } on UnauthorizedException catch (e) {
      return Failure(e.message, statusCode: 401);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // ─── Talep Oluştur ────────────────────────────────────────────────────────

  @override
  Future<Result<GenerationRequestEntity>> createTemplateGeneration({
    required GenerationType type,
    required String templateId,
    required String imagePath,
    String? orientation,
  }) async {
    try {
      final model = await _datasource.createTemplateGeneration(
        type: _generationTypeToString(type),
        templateId: templateId,
        imagePath: imagePath,
        orientation: orientation,
      );
      return Success(model.toEntity());
    } on UnauthorizedException catch (e) {
      return Failure(e.message, statusCode: 401);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // ─── Talep Listesi ────────────────────────────────────────────────────────

  @override
  Future<Result<List<GenerationRequestEntity>>> getGenerationRequests() async {
    try {
      final models = await _datasource.getGenerationRequests();
      return Success(models.map((m) => m.toEntity()).toList());
    } on UnauthorizedException catch (e) {
      return Failure(e.message, statusCode: 401);
    } on ServerException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } on NetworkException catch (e) {
      return Failure(e.message);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  // ─── Yardımcı ─────────────────────────────────────────────────────────────

  String _generationTypeToString(GenerationType type) => switch (type) {
        GenerationType.templateImage => 'template_image',
        GenerationType.templateVideo => 'template_video',
      };
}