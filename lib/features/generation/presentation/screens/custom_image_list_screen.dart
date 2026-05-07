// lib/features/generation/presentation/screens/custom_image_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:asilov/core/constants/app_colors.dart';
import 'package:asilov/features/generation/domain/entities/generation_request_entity.dart';
import 'package:asilov/features/generation/presentation/providers/generation_provider.dart';
import 'package:asilov/l10n/app_localizations.dart';

class CustomImageListScreen extends ConsumerStatefulWidget {
  const CustomImageListScreen({super.key});

  @override
  ConsumerState<CustomImageListScreen> createState() =>
      _CustomImageListScreenState();
}

class _CustomImageListScreenState
    extends ConsumerState<CustomImageListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(customImageListProvider.notifier).refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final requestsAsync = ref.watch(customImageListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.navImages,
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
                ref.read(customImageListProvider.notifier).refresh(),
          ),
        ],
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
              ref.read(customImageListProvider.notifier).refresh(),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return _EmptyView(message: l10n.noImages);
          }

          return RefreshIndicator(
            color: AppColors.gold,
            backgroundColor: AppColors.surface,
            onRefresh: () =>
                ref.read(customImageListProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: requests.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _ImageRequestCard(request: requests[i]),
            ),
          );
        },
      ),
    );
  }
}

// ─── Image Request Card ───────────────────────────────────────────────────────

class _ImageRequestCard extends StatelessWidget {
  final GenerationRequestEntity request;

  const _ImageRequestCard({required this.request});

  String? get _downloadUrl => request.outputImageUrl;

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          // ── Progress ──
          _CircularProgress(progress: request.progress),
          const SizedBox(width: 16),

          // ── Bilgiler ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (request.orientation != null)
                  _OrientationBadge(orientation: request.orientation!),
                if (request.orientation != null) const SizedBox(height: 6),
                if (request.description != null &&
                    request.description!.isNotEmpty)
                  Text(
                    request.description!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (request.description != null &&
                    request.description!.isNotEmpty)
                  const SizedBox(height: 6),
                Text(
                  _formatDate(request.createdAt),
                  style: const TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 6),
                _StatusBadge(status: request.status),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── İndir Butonu ──
          if (request.status == GenerationStatus.completed &&
              _downloadUrl != null)
            _DownloadButton(url: _downloadUrl!, l10n: l10n),
        ],
      ),
    );
  }
}

// ─── Circular Progress ────────────────────────────────────────────────────────

class _CircularProgress extends StatelessWidget {
  final int progress;

  const _CircularProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress / 100,
            strokeWidth: 5,
            backgroundColor: AppColors.gold.withValues(alpha: 0.15),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.gold),
          ),
          Center(
            child: Text(
              '%$progress',
              style: const TextStyle(
                color: AppColors.textPrimary,
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

// ─── Orientation Badge ────────────────────────────────────────────────────────

class _OrientationBadge extends StatelessWidget {
  final String orientation;

  const _OrientationBadge({required this.orientation});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final label = switch (orientation) {
      'landscape' => l10n.landscape,
      'square'    => l10n.square,
      _           => l10n.portrait,
    };

    final icon = switch (orientation) {
      'landscape' => Icons.crop_landscape_outlined,
      'square'    => Icons.crop_square_outlined,
      _           => Icons.crop_portrait_outlined,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.gold, size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final GenerationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (label, color) = switch (status) {
      GenerationStatus.pending    => (l10n.requestPending,    const Color(0xFFF5A623)),
      GenerationStatus.processing => (l10n.requestProcessing, const Color(0xFF4A9EFF)),
      GenerationStatus.completed  => (l10n.requestCompleted,  const Color(0xFF4CAF50)),
      GenerationStatus.failed     => (l10n.requestFailed,     const Color(0xFFE53935)),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Download Button ──────────────────────────────────────────────────────────

class _DownloadButton extends StatelessWidget {
  final String url;
  final AppLocalizations l10n;

  const _DownloadButton({required this.url, required this.l10n});

  Future<void> _download(BuildContext context) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.downloadError),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _download(context),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gold, Color(0xFFF5D97A)],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.download_rounded,
                color: AppColors.background, size: 20),
            const SizedBox(height: 3),
            Text(
              l10n.download,
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
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
          const Icon(Icons.image_outlined,
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