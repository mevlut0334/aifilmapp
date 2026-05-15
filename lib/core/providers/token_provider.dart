import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asilov/core/network/api_client.dart';
import 'package:asilov/features/auth/presentation/providers/auth_provider.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final tokenBalanceProvider = AsyncNotifierProvider<TokenBalanceNotifier, int>(
  TokenBalanceNotifier.new,
);

// ─── Notifier ─────────────────────────────────────────────────────────────────

class TokenBalanceNotifier extends AsyncNotifier<int> {
  int _customImageTokenCost = 50;
  int get customImageTokenCost => _customImageTokenCost;
  @override
  Future<int> build() async {
    // authProvider'ı dinle — status değişince build() yeniden çalışır
    final authState = ref.watch(authProvider);

    // Sadece authenticated ise istek at
    if (authState.status != AuthStatus.authenticated) {
      return 0;
    }

    return _fetchBalance();
  }

  Future<int> _fetchBalance() async {
    final dio = ref.read(apiClientProvider);
    try {
      final response = await dio.get('/tokens/balance');
      final data = response.data;

      if (data['success'] == true) {
        _customImageTokenCost =
            (data['data']['custom_image_token_cost'] as num?)?.toInt() ?? 50;
        return (data['data']['balance'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return 0;
      return 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> refresh() async {
    final authState = ref.read(authProvider);
    if (authState.status != AuthStatus.authenticated) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchBalance);
  }
}

final customImageTokenCostProvider = Provider<int>((ref) {
  ref.watch(tokenBalanceProvider);
  return ref.read(tokenBalanceProvider.notifier).customImageTokenCost;
});
