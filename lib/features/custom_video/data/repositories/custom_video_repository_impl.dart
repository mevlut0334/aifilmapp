import 'dart:io';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/custom_video_request_entity.dart';
import '../../domain/repositories/custom_video_repository.dart';
import '../datasources/custom_video_remote_datasource.dart';

class CustomVideoRepositoryImpl implements CustomVideoRepository {
  final CustomVideoRemoteDatasource _datasource;

  const CustomVideoRepositoryImpl(this._datasource);

  // ─── Talep Oluştur ────────────────────────────────────────────────────────

  @override
  Future<Result<CustomVideoRequestEntity>> createCustomVideoRequest({
    required String prompt,
    required CustomVideoFormat format,
    File? inputImage,
  }) async {
    try {
      final model = await _datasource.createCustomVideoRequest(
        prompt: prompt,
        format: _formatToString(format),
        inputImage: inputImage,
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
  Future<Result<List<CustomVideoRequestEntity>>> getCustomVideoRequests() async {
    try {
      final models = await _datasource.getCustomVideoRequests();
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

  // ─── Talep Detayı ─────────────────────────────────────────────────────────

  @override
  Future<Result<CustomVideoRequestEntity>> getCustomVideoDetail(
      String uuid) async {
    try {
      final model = await _datasource.getCustomVideoDetail(uuid);
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

  // ─── Segment Düzenleme ────────────────────────────────────────────────────

  @override
  Future<Result<void>> editSegment({
    required String uuid,
    required int segmentId,
    required String editPrompt,
  }) async {
    try {
      await _datasource.editSegment(
        uuid: uuid,
        segmentId: segmentId,
        editPrompt: editPrompt,
      );
      return const Success(null);
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

  String _formatToString(CustomVideoFormat format) => switch (format) {
        CustomVideoFormat.vertical   => 'vertical',
        CustomVideoFormat.horizontal => 'horizontal',
        CustomVideoFormat.square     => 'square',
      };
}