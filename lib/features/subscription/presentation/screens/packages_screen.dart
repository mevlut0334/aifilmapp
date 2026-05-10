// lib/features/subscription/presentation/screens/packages_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:asilov/l10n/app_localizations.dart';
import 'package:asilov/core/constants/app_colors.dart';
import 'package:asilov/features/auth/presentation/providers/auth_provider.dart';
import 'package:asilov/features/subscription/domain/entities/mobile_package_entity.dart';
import 'package:asilov/features/subscription/domain/entities/subscription_status_entity.dart';
import 'package:asilov/features/subscription/presentation/providers/subscription_provider.dart';

class PackagesScreen extends ConsumerStatefulWidget {
  const PackagesScreen({super.key});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(purchaseProvider, (previous, next) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;

        if (next.status == BuyStatus.success) {
          final tokens = next.tokensAdded;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                tokens != null
                    ? l10n.purchaseSuccessTokens(tokens)
                    : l10n.subscriptionSuccess,
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(purchaseProvider.notifier).reset();
          ref.invalidate(subscriptionStatusProvider);
        } else if (next.status == BuyStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? l10n.purchaseFailed),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
          ref.read(purchaseProvider.notifier).reset();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final packages = ref.watch(mobilePackagesProvider);
    final statusAsync = ref.watch(subscriptionStatusProvider);
    final purchaseState = ref.watch(purchaseProvider);
    final authState = ref.watch(authProvider);
    final platform = ref.watch(currentPlatformProvider);

    final isLoggedIn = authState.status == AuthStatus.authenticated;
    final isPurchasing = purchaseState.status == BuyStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          l10n.packages,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF2A2A2A), height: 1),
        ),
      ),
      body: packages.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (e, _) => _ErrorBody(
          message: e.toString(),
          onRetry: () => ref.invalidate(mobilePackagesProvider),
        ),
        data: (pkgList) => _Body(
          packages: pkgList,
          statusAsync: statusAsync,
          platform: platform,
          isPurchasing: isPurchasing,
          isLoggedIn: isLoggedIn,
          onSubscribe: (pkg) {
            if (!isLoggedIn) {
              context.go('/login');
              return;
            }
            ref.read(purchaseProvider.notifier).buyPackage(pkg);
          },
          onRefresh: () async {
            ref.invalidate(mobilePackagesProvider);
            ref.invalidate(subscriptionStatusProvider);
          },
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final List<MobilePackageEntity> packages;
  final AsyncValue<SubscriptionStatusEntity?> statusAsync;
  final String platform;
  final bool isPurchasing;
  final bool isLoggedIn;
  final void Function(MobilePackageEntity) onSubscribe;
  final Future<void> Function() onRefresh;

  const _Body({
    required this.packages,
    required this.statusAsync,
    required this.platform,
    required this.isPurchasing,
    required this.isLoggedIn,
    required this.onSubscribe,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = statusAsync.valueOrNull;

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ Banner ─
            _HeaderBanner(),
            const SizedBox(height: 24),

            // ─ Giriş uyarısı ─
            if (!isLoggedIn) ...[
              _LoginWarning(),
              const SizedBox(height: 20),
            ],

            // ─ Aktif abonelik ─
            if (status != null && status.isActive) ...[
              _ActiveSubscriptionCard(status: status),
              const SizedBox(height: 24),
            ],

            // ─ Paket listesi ─
            if (packages.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    l10n.noPackagesAvailable,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              ...packages.map((pkg) {
                final isCurrentPlan = status != null &&
                    status.isActive &&
                    status.packageId == pkg.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PackageCard(
                    package: pkg,
                    isCurrentPlan: isCurrentPlan,
                    isPurchasing: isPurchasing,
                    isLoggedIn: isLoggedIn,
                    onSubscribe: () => onSubscribe(pkg),
                  ),
                );
              }),

            const SizedBox(height: 16),
            _Footer(platform: platform),
          ],
        ),
      ),
    );
  }
}

// ─── Header Banner ────────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.15),
            AppColors.gold.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.diamond_outlined, color: AppColors.gold, size: 40),
          const SizedBox(height: 16),
          Text(
            l10n.premiumTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.premiumSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Login Warning ────────────────────────────────────────────────────────────

class _LoginWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.loginToSubscribe,
              style: const TextStyle(color: AppColors.gold, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/login'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              l10n.loginButton,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Active Subscription Card ─────────────────────────────────────────────────

class _ActiveSubscriptionCard extends StatelessWidget {
  final SubscriptionStatusEntity status;

  const _ActiveSubscriptionCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final expiresAt = status.expiresAt;

    final formattedDate = expiresAt != null
        ? '${expiresAt.day.toString().padLeft(2, '0')}.'
            '${expiresAt.month.toString().padLeft(2, '0')}.'
            '${expiresAt.year}'
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.activeSubscription,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (formattedDate != null)
                  Text(
                    l10n.subscriptionExpiry(formattedDate),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (status.autoRenewing)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l10n.autoRenewing,
                style: const TextStyle(color: Colors.green, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Package Card ─────────────────────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  final MobilePackageEntity package;
  final bool isCurrentPlan;
  final bool isPurchasing;
  final bool isLoggedIn;
  final VoidCallback onSubscribe;

  const _PackageCard({
    required this.package,
    required this.isCurrentPlan,
    required this.isPurchasing,
    required this.isLoggedIn,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final buttonDisabled = isCurrentPlan || isPurchasing;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrentPlan ? AppColors.gold : const Color(0xFF2A2A2A),
          width: isCurrentPlan ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─ Başlık ─
            Row(
              children: [
                Expanded(
                  child: Text(
                    package.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCurrentPlan)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      l10n.currentPlan,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // ─ Token ─
            Row(
              children: [
                const Icon(Icons.toll_outlined,
                    color: AppColors.gold, size: 18),
                const SizedBox(width: 6),
                Text(
                  '${package.tokenAmount} ${l10n.tokens}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            if (package.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                package.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ─ Buton ─
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: buttonDisabled ? null : onSubscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isCurrentPlan ? AppColors.surface : AppColors.gold,
                  foregroundColor: isCurrentPlan
                      ? AppColors.textSecondary
                      : AppColors.background,
                  disabledBackgroundColor: isCurrentPlan
                      ? AppColors.surface
                      : AppColors.gold.withValues(alpha: 0.5),
                  disabledForegroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: isCurrentPlan
                        ? const BorderSide(color: Color(0xFF2A2A2A))
                        : BorderSide.none,
                  ),
                  elevation: 0,
                ),
                child: isPurchasing && !isCurrentPlan
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : Text(
                        isCurrentPlan
                            ? l10n.activePlan
                            : isLoggedIn
                                ? l10n.subscribe
                                : l10n.loginAndSubscribe,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final String platform;

  const _Footer({required this.platform});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const Divider(color: Color(0xFF2A2A2A)),
        const SizedBox(height: 12),
        Text(
          l10n.subscriptionRenewalNote,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textDisabled,
            fontSize: 11,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          platform == 'ios' ? l10n.applePaymentTerms : l10n.googlePaymentTerms,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textDisabled,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ─── Error Body ───────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
