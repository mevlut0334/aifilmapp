import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asilov/core/network/api_client.dart';
import 'package:asilov/features/home/data/models/slider_model.dart';

final sliderProvider = AsyncNotifierProvider<SliderNotifier, List<SliderModel>>(
  SliderNotifier.new,
);

class SliderNotifier extends AsyncNotifier<List<SliderModel>> {
  @override
  Future<List<SliderModel>> build() async {
    return _fetchSliders();
  }

  Future<List<SliderModel>> _fetchSliders() async {
    final dio = ref.read(apiClientProvider);
    try {
      final response = await dio.get('/sliders');
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        final list = data['data'] as List<dynamic>;
        return list
            .map((e) => SliderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}