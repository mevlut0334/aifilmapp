import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:asilov/core/constants/app_colors.dart';
import 'package:asilov/features/custom_video/domain/entities/custom_video_request_entity.dart';
import 'package:asilov/features/custom_video/presentation/providers/custom_video_provider.dart';
import 'package:asilov/l10n/app_localizations.dart';

class CustomVideoListScreen extends ConsumerStatefulWidget {
  const CustomVideoListScreen({super.key});

  @override
  ConsumerState<CustomVideoListScreen> createState() =>
      _CustomVideoListScreenState();
}

class _CustomVideoListScreenState
    extends ConsumerState<CustomVideoListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(customVideoListProvider.notifier).refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final requestsAsync = ref.watch(customVideoListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.videoRequests,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.gold),
            onPressed: () =>
                ref.read(customVideoListProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: () => context.go('/create-video'),
        child: const Icon(Icons.add, color: AppColors.background),
      ),
      body: requestsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 2,
          ),
        ),
        error: (error, _) => _ErrorView(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () =>
              ref.read(customVideoListProvider.notifier).refresh(),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return _EmptyView(message: l10n.noVideoRequests);
          }
          return RefreshIndicator(
            color: AppColors.gold,
            backgroundColor: AppColors.surface,
            onRefresh: () =>
                ref.read(customVideoListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _VideoRequestCard(
                request: requests[i],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Video Request Card ───────────────────────────────────────────────────────

class _VideoRequestCard extends StatelessWidget {
  final CustomVideoRequestEntity request;

  const _VideoRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => context.push('/video-detail/${request.uuid}'), // go → push
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Üst satır: format badge + durum ──
            Row(
              children: [
                _FormatBadge(format: request.format),
                const SizedBox(width: 8),
                _StatusBadge(status: request.status),
                const Spacer(),
                Text(
                  _formatDate(request.createdAt),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Prompt ──
            Text(
              request.prompt,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),

            // ── Progress bar ──
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: request.overallProgress / 100,
                      backgroundColor:
                          AppColors.gold.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        request.isCompleted
                            ? const Color(0xFF4CAF50)
                            : AppColors.gold,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '%${request.overallProgress}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            // ── Segment bilgisi ──
            if (request.segmentsCount != null &&
                request.segmentsCount! > 0) ...[
              const SizedBox(height: 6),
              Text(
                '${request.completedSegments ?? 0}/${request.segmentsCount} segment',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],

            // ── İndir butonu (tamamlandıysa) ──
            if (request.isCompleted) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFF2A2A2A), height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF4CAF50),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.requestCompleted,
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _DetailButton(uuid: request.uuid, l10n: l10n),
                ],
              ),
            ],

            // ── Hata mesajı ──
            if (request.isFailed &&
                request.failureReason != null) ...[
              const SizedBox(height: 8),
              Text(
                request.failureReason!,
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Detail Button ────────────────────────────────────────────────────────────

class _DetailButton extends StatelessWidget {
  final String uuid;
  final AppLocalizations l10n;

  const _DetailButton({required this.uuid, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/video-detail/$uuid'), // go → push
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gold, Color(0xFFF5D97A)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          l10n.videoRequestDetail,
          style: const TextStyle(
            color: AppColors.background,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── Format Badge ─────────────────────────────────────────────────────────────

class _FormatBadge extends StatelessWidget {
  final CustomVideoFormat format;

  const _FormatBadge({required this.format});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final label = switch (format) {
      CustomVideoFormat.vertical   => l10n.formatVertical,
      CustomVideoFormat.horizontal => l10n.formatHorizontal,
      CustomVideoFormat.square     => l10n.formatSquare,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.gold,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final CustomVideoStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (label, color) = switch (status) {
      CustomVideoStatus.pending    => (l10n.requestPending,    const Color(0xFFF5A623)),
      CustomVideoStatus.processing => (l10n.requestProcessing, const Color(0xFF4A9EFF)),
      CustomVideoStatus.completed  => (l10n.requestCompleted,  const Color(0xFF4CAF50)),
      CustomVideoStatus.failed     => (l10n.requestFailed,     const Color(0xFFE53935)),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Empty View ───────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String message;

  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam_off_outlined,
              color: AppColors.textDisabled, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
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

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                color: AppColors.textDisabled, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(
                l10n.retry,
                style: const TextStyle(color: AppColors.gold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}