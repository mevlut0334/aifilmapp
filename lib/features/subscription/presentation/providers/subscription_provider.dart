import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/entities/mobile_package_entity.dart';
import '../../domain/entities/subscription_status_entity.dart';
import '../../domain/usecases/get_mobile_packages_usecase.dart';
import '../../domain/usecases/get_subscription_status_usecase.dart';
import '../../domain/usecases/verify_android_purchase_usecase.dart';
import '../../domain/usecases/verify_ios_purchase_usecase.dart';

// ─── Platform ────────────────────────────────────────────────────────────────

final currentPlatformProvider = Provider<String>((ref) {
  return Platform.isIOS ? 'ios' : 'android';
});

// ─── Infrastructure ───────────────────────────────────────────────────────────

final subscriptionRemoteDatasourceProvider =
    Provider<SubscriptionRemoteDatasource>((ref) {
  return SubscriptionRemoteDatasourceImpl(ref.watch(apiClientProvider));
});

final subscriptionRepositoryProvider =
    Provider<SubscriptionRepositoryImpl>((ref) {
  return SubscriptionRepositoryImpl(
    ref.watch(subscriptionRemoteDatasourceProvider),
  );
});

// ─── UseCase Providers ────────────────────────────────────────────────────────

final getMobilePackagesUseCaseProvider =
    Provider<GetMobilePackagesUseCase>((ref) {
  return GetMobilePackagesUseCase(ref.watch(subscriptionRepositoryProvider));
});

final verifyIosPurchaseUseCaseProvider =
    Provider<VerifyIosPurchaseUseCase>((ref) {
  return VerifyIosPurchaseUseCase(ref.watch(subscriptionRepositoryProvider));
});

final verifyAndroidPurchaseUseCaseProvider =
    Provider<VerifyAndroidPurchaseUseCase>((ref) {
  return VerifyAndroidPurchaseUseCase(ref.watch(subscriptionRepositoryProvider));
});

final getSubscriptionStatusUseCaseProvider =
    Provider<GetSubscriptionStatusUseCase>((ref) {
  return GetSubscriptionStatusUseCase(ref.watch(subscriptionRepositoryProvider));
});

// ─── Mobile Packages ──────────────────────────────────────────────────────────

final mobilePackagesProvider =
    AsyncNotifierProvider<MobilePackagesNotifier, List<MobilePackageEntity>>(
  MobilePackagesNotifier.new,
);

class MobilePackagesNotifier
    extends AsyncNotifier<List<MobilePackageEntity>> {
  @override
  Future<List<MobilePackageEntity>> build() async {
    final platform = ref.read(currentPlatformProvider);
    return _fetchPackages(platform);
  }

  Future<List<MobilePackageEntity>> _fetchPackages(String platform) async {
    final useCase = ref.read(getMobilePackagesUseCaseProvider);
    final result = await useCase(platform);
    return result.when(
      success: (data) => data,
      failure: (message, _) => throw Exception(message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final platform = ref.read(currentPlatformProvider);
    state = await AsyncValue.guard(() => _fetchPackages(platform));
  }
}

// ─── Subscription Status ──────────────────────────────────────────────────────

final subscriptionStatusProvider =
    AsyncNotifierProvider<SubscriptionStatusNotifier, SubscriptionStatusEntity?>(
  SubscriptionStatusNotifier.new,
);

class SubscriptionStatusNotifier
    extends AsyncNotifier<SubscriptionStatusEntity?> {
  @override
  Future<SubscriptionStatusEntity?> build() async {
    final platform = ref.read(currentPlatformProvider);
    return _fetchStatus(platform);
  }

  Future<SubscriptionStatusEntity?> _fetchStatus(String platform) async {
    final useCase = ref.read(getSubscriptionStatusUseCaseProvider);
    final result = await useCase(platform);
    return result.when(
      success: (data) => data,
      failure: (_, __) => null,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final platform = ref.read(currentPlatformProvider);
    state = await AsyncValue.guard(() => _fetchStatus(platform));
  }
}

// ─── Purchase State ───────────────────────────────────────────────────────────

enum BuyStatus { idle, loading, success, error }

class PurchaseState {
  final BuyStatus status;
  final String? errorMessage;
  final int? tokensAdded;

  const PurchaseState({
    this.status = BuyStatus.idle,
    this.errorMessage,
    this.tokensAdded,
  });

  PurchaseState copyWith({
    BuyStatus? status,
    String? errorMessage,
    int? tokensAdded,
  }) {
    return PurchaseState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      tokensAdded: tokensAdded ?? this.tokensAdded,
    );
  }
}

final purchaseProvider =
    NotifierProvider<PurchaseNotifier, PurchaseState>(
  PurchaseNotifier.new,
);

class PurchaseNotifier extends Notifier<PurchaseState> {
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  @override
  PurchaseState build() {
    ref.onDispose(() => _subscription?.cancel());
    _listenToPurchaseUpdates();
    return const PurchaseState();
  }

  void _listenToPurchaseUpdates() {
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      (purchases) => _handlePurchaseUpdates(purchases),
      onError: (error) {
        state = state.copyWith(
          status: BuyStatus.error,
          errorMessage: error.toString(),
        );
      },
    );
  }

  Future<void> _handlePurchaseUpdates(
      List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.error) {
        state = state.copyWith(
          status: BuyStatus.error,
          errorMessage: purchase.error?.message ?? 'Purchase failed',
        );
        await InAppPurchase.instance.completePurchase(purchase);
        continue;
      }

      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _verifyWithBackend(purchase);
      }
    }
  }

  Future<void> _verifyWithBackend(PurchaseDetails purchase) async {
    state = state.copyWith(status: BuyStatus.loading);

    Result<Map<String, dynamic>> result;

    if (Platform.isIOS) {
      final receiptData = purchase.verificationData.serverVerificationData;
      result = await ref.read(verifyIosPurchaseUseCaseProvider).call(
            productId: purchase.productID,
            receiptData: receiptData,
          );
    } else {
      result = await ref.read(verifyAndroidPurchaseUseCaseProvider).call(
            productId: purchase.productID,
            purchaseToken: purchase.verificationData.serverVerificationData,
            packageName: 'com.asilov.app',
          );
    }

    result.when(
      success: (data) {
        state = state.copyWith(
          status: BuyStatus.success,
          tokensAdded: data['tokens_added'] as int?,
        );
        ref.invalidate(subscriptionStatusProvider);
      },
      failure: (message, _) {
        state = state.copyWith(
          status: BuyStatus.error,
          errorMessage: message,
        );
      },
    );
  }

  Future<void> buyPackage(MobilePackageEntity package) async {
    state = state.copyWith(status: BuyStatus.loading);

    final isAvailable = await InAppPurchase.instance.isAvailable();
    if (!isAvailable) {
      state = state.copyWith(
        status: BuyStatus.error,
        errorMessage: 'Store is not available',
      );
      return;
    }

    final productId = Platform.isIOS
        ? package.iosProductId
        : package.androidProductId;

    final response = await InAppPurchase.instance
        .queryProductDetails({productId});

    if (response.productDetails.isEmpty) {
      state = state.copyWith(
        status: BuyStatus.error,
        errorMessage: 'Product not found',
      );
      return;
    }

    final purchaseParam = PurchaseParam(
      productDetails: response.productDetails.first,
    );

    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
  }

  void reset() {
    state = const PurchaseState();
  }
}