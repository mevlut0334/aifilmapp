import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/custom_video_remote_datasource.dart';
import '../../data/repositories/custom_video_repository_impl.dart';
import '../../domain/entities/custom_video_request_entity.dart';
import '../../domain/usecases/create_custom_video_usecase.dart';
import '../../domain/usecases/edit_segment_usecase.dart';
import '../../domain/usecases/get_custom_video_detail_usecase.dart';
import '../../domain/usecases/get_custom_video_requests_usecase.dart';

// ─── Infrastructure Providers ─────────────────────────────────────────────────

final customVideoRemoteDatasourceProvider =
    Provider<CustomVideoRemoteDatasource>((ref) {
  return CustomVideoRemoteDatasource(ref.watch(apiClientProvider));
});

final customVideoRepositoryProvider =
    Provider<CustomVideoRepositoryImpl>((ref) {
  return CustomVideoRepositoryImpl(
    ref.watch(customVideoRemoteDatasourceProvider),
  );
});

// ─── UseCase Providers ────────────────────────────────────────────────────────

final createCustomVideoUsecaseProvider =
    Provider<CreateCustomVideoUsecase>((ref) {
  return CreateCustomVideoUsecase(ref.watch(customVideoRepositoryProvider));
});

final getCustomVideoRequestsUsecaseProvider =
    Provider<GetCustomVideoRequestsUsecase>((ref) {
  return GetCustomVideoRequestsUsecase(
      ref.watch(customVideoRepositoryProvider));
});

final getCustomVideoDetailUsecaseProvider =
    Provider<GetCustomVideoDetailUsecase>((ref) {
  return GetCustomVideoDetailUsecase(ref.watch(customVideoRepositoryProvider));
});

final editSegmentUsecaseProvider = Provider<EditSegmentUsecase>((ref) {
  return EditSegmentUsecase(ref.watch(customVideoRepositoryProvider));
});

// ─── Custom Video List ────────────────────────────────────────────────────────

final customVideoListProvider = AsyncNotifierProvider<CustomVideoListNotifier,
    List<CustomVideoRequestEntity>>(
  CustomVideoListNotifier.new,
);

class CustomVideoListNotifier
    extends AsyncNotifier<List<CustomVideoRequestEntity>> {
  @override
  Future<List<CustomVideoRequestEntity>> build() async {
    return _fetchRequests();
  }

  Future<List<CustomVideoRequestEntity>> _fetchRequests() async {
    final usecase = ref.read(getCustomVideoRequestsUsecaseProvider);
    final result = await usecase();

    return switch (result) {
      Success<List<CustomVideoRequestEntity>> s => s.data,
      Failure<List<CustomVideoRequestEntity>> f =>
        throw Exception(f.message),
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchRequests);
  }
}

// ─── Custom Video Detail ──────────────────────────────────────────────────────

final customVideoDetailProvider =
    AsyncNotifierProvider.family<CustomVideoDetailNotifier,
        CustomVideoRequestEntity, String>(
  CustomVideoDetailNotifier.new,
);

class CustomVideoDetailNotifier
    extends FamilyAsyncNotifier<CustomVideoRequestEntity, String> {
  @override
  Future<CustomVideoRequestEntity> build(String arg) async {
    return _fetchDetail(arg);
  }

  Future<CustomVideoRequestEntity> _fetchDetail(String uuid) async {
    final usecase = ref.read(getCustomVideoDetailUsecaseProvider);
    final result = await usecase(uuid);

    return switch (result) {
      Success<CustomVideoRequestEntity> s => s.data,
      Failure<CustomVideoRequestEntity> f => throw Exception(f.message),
    };
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchDetail(arg));
  }

  Future<bool> editSegment({
    required int segmentId,
    required String editPrompt,
  }) async {
    final usecase = ref.read(editSegmentUsecaseProvider);
    final result = await usecase(
      uuid: arg,
      segmentId: segmentId,
      editPrompt: editPrompt,
    );

    switch (result) {
      case Success():
        await refresh();
        return true;
      case Failure<void> f:
        throw Exception(f.message);
    }
  }
}