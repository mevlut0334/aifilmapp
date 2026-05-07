import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/generation_remote_datasource.dart';
import '../../data/repositories/generation_repository_impl.dart';
import '../../domain/entities/generation_request_entity.dart';
import '../../domain/usecases/get_generation_requests_usecase.dart';

// ─── Infrastructure Providers ─────────────────────────────────────────────────

final generationRemoteDatasourceProvider =
    Provider<GenerationRemoteDatasource>((ref) {
  return GenerationRemoteDatasource(ref.watch(apiClientProvider));
});

final generationRepositoryProvider =
    Provider<GenerationRepositoryImpl>((ref) {
  return GenerationRepositoryImpl(
    ref.watch(generationRemoteDatasourceProvider),
  );
});

// ─── UseCase Providers ────────────────────────────────────────────────────────

final getGenerationRequestsUseCaseProvider =
    Provider<GetGenerationRequestsUseCase>((ref) {
  return GetGenerationRequestsUseCase(ref.watch(generationRepositoryProvider));
});

// ─── Generation List ──────────────────────────────────────────────────────────

final generationListProvider =
    AsyncNotifierProvider<GenerationListNotifier, List<GenerationRequestEntity>>(
  GenerationListNotifier.new,
);

class GenerationListNotifier
    extends AsyncNotifier<List<GenerationRequestEntity>> {
  @override
  Future<List<GenerationRequestEntity>> build() async {
    return _fetchRequests();
  }

  Future<List<GenerationRequestEntity>> _fetchRequests() async {
    final useCase = ref.read(getGenerationRequestsUseCaseProvider);
    final result = await useCase();

    return result.when(
      success: (data) => data,
      failure: (message, statusCode) => throw Exception(message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchRequests);
  }
}

// ─── Custom Image List ────────────────────────────────────────────────────────

final customImageListProvider =
    AsyncNotifierProvider<CustomImageListNotifier, List<GenerationRequestEntity>>(
  CustomImageListNotifier.new,
);

class CustomImageListNotifier
    extends AsyncNotifier<List<GenerationRequestEntity>> {
  @override
  Future<List<GenerationRequestEntity>> build() async {
    return _fetchRequests();
  }

  Future<List<GenerationRequestEntity>> _fetchRequests() async {
    final datasource = ref.read(generationRemoteDatasourceProvider);
    final models = await datasource.getCustomImageRequests();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchRequests);
  }
}