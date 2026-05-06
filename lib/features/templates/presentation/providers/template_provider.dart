import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asilov/core/network/api_client.dart';
import 'package:asilov/core/utils/result.dart';
import 'package:asilov/features/templates/data/datasources/template_remote_datasource.dart';
import 'package:asilov/features/templates/data/repositories/template_repository_impl.dart';
import 'package:asilov/features/templates/domain/entities/template_entity.dart';
import 'package:asilov/features/templates/domain/usecases/get_template_detail_usecase.dart';
import 'package:asilov/features/templates/domain/usecases/get_templates_usecase.dart';

// --- Dependency Providers ---

final templateRemoteDataSourceProvider = Provider<TemplateRemoteDataSource>((ref) {
  return TemplateRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final templateRepositoryProvider = Provider<TemplateRepositoryImpl>((ref) {
  return TemplateRepositoryImpl(ref.watch(templateRemoteDataSourceProvider));
});

final getTemplatesUseCaseProvider = Provider<GetTemplatesUseCase>((ref) {
  return GetTemplatesUseCase(ref.watch(templateRepositoryProvider));
});

final getTemplateDetailUseCaseProvider = Provider<GetTemplateDetailUseCase>((ref) {
  return GetTemplateDetailUseCase(ref.watch(templateRepositoryProvider));
});

// --- State Providers ---

final templateListProvider = AsyncNotifierProvider<TemplateListNotifier, List<TemplateEntity>>(
  TemplateListNotifier.new,
);

class TemplateListNotifier extends AsyncNotifier<List<TemplateEntity>> {
  String? _selectedOrientation;

  @override
  Future<List<TemplateEntity>> build() async {
    return _fetchTemplates();
  }

  Future<List<TemplateEntity>> _fetchTemplates() async {
    final useCase = ref.read(getTemplatesUseCaseProvider);
    final result = await useCase(orientation: _selectedOrientation);

    return result.when(
      success: (data) => data,
      failure: (message, statusCode) => throw Exception(message),
    );
  }

  Future<void> filterByOrientation(String? orientation) async {
    _selectedOrientation = orientation;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchTemplates);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchTemplates);
  }
}

final templateDetailProvider = AsyncNotifierProviderFamily<TemplateDetailNotifier, TemplateEntity, String>(
  TemplateDetailNotifier.new,
);

class TemplateDetailNotifier extends FamilyAsyncNotifier<TemplateEntity, String> {
  @override
  Future<TemplateEntity> build(String arg) async {
    final useCase = ref.read(getTemplateDetailUseCaseProvider);
    final result = await useCase(arg);

    return result.when(
      success: (data) => data,
      failure: (message, statusCode) => throw Exception(message),
    );
  }
}