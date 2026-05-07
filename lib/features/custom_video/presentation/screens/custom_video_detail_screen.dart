import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:asilov/core/constants/app_colors.dart';
import 'package:asilov/features/custom_video/domain/entities/custom_video_request_entity.dart';
import 'package:asilov/features/custom_video/presentation/providers/custom_video_provider.dart';
import 'package:asilov/l10n/app_localizations.dart';

class CustomVideoDetailScreen extends ConsumerStatefulWidget {
  final String uuid;

  const CustomVideoDetailScreen({super.key, required this.uuid});

  @override
  ConsumerState<CustomVideoDetailScreen> createState() =>
      _CustomVideoDetailScreenState();
}

class _CustomVideoDetailScreenState
    extends ConsumerState<CustomVideoDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(customVideoDetailProvider(widget.uuid).notifier)
          .refresh(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final detailAsync = ref.watch(customVideoDetailProvider(widget.uuid));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.videoRequestDetail,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.gold),
            onPressed: () => ref
                .read(customVideoDetailProvider(widget.uuid).notifier)
                .refresh(),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 2,
          ),
        ),
        error: (error, _) => _ErrorView(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref
              .read(customVideoDetailProvider(widget.uuid).notifier)
              .refresh(),
        ),
        data: (request) => _DetailBody(request: request, uuid: widget.uuid),
      ),
    );
  }
}

// ─── Detail Body ──────────────────────────────────────────────────────────────

class _DetailBody extends ConsumerWidget {
  final CustomVideoRequestEntity request;
  final String uuid;

  const _DetailBody({required this.request, required this.uuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.surface,
      onRefresh: () =>
          ref.read(customVideoDetailProvider(uuid).notifier).refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Genel Bilgiler ──
          _InfoCard(request: request),
          const SizedBox(height: 16),

          // ── Segmentler ──
          Text(
            l10n.segmentsTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          if (request.segments.isEmpty)
            _EmptySegments(message: l10n.noSegmentsYet)
          else
            ...request.segments.map(
              (segment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SegmentCard(
                  segment: segment,
                  uuid: uuid,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final CustomVideoRequestEntity request;

  const _InfoCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Durum + Format
          Row(
            children: [
              _StatusBadge(status: request.status),
              const SizedBox(width: 8),
              _FormatBadge(format: request.format),
            ],
          ),
          const SizedBox(height: 12),

          // Prompt
          Text(
            request.prompt,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),

          // Genel ilerleme
          Text(
            l10n.overallProgress,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: request.overallProgress / 100,
                    backgroundColor: AppColors.gold.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      request.isCompleted
                          ? const Color(0xFF4CAF50)
                          : AppColors.gold,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '%${request.overallProgress}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Token maliyeti
          if (request.tokenCost != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.toll_outlined,
                    color: AppColors.gold, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${l10n.tokenCost}: ${request.tokenCost}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],

          // Hata mesajı
          if (request.isFailed && request.failureReason != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: const Color(0xFFE53935).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      color: Color(0xFFE53935), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      request.failureReason!,
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Segment Card ─────────────────────────────────────────────────────────────

class _SegmentCard extends ConsumerWidget {
  final SegmentEntity segment;
  final String uuid;

  const _SegmentCard({required this.segment, required this.uuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segment başlık + durum
          Row(
            children: [
              Text(
                '${l10n.segmentNumber} ${segment.segmentNumber}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _SegmentStatusBadge(status: segment.status),
            ],
          ),
          const SizedBox(height: 10),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: segment.progress / 100,
                    backgroundColor:
                        AppColors.gold.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      segment.isCompleted
                          ? const Color(0xFF4CAF50)
                          : AppColors.gold,
                    ),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '%${segment.progress}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          // Hata mesajı
          if (segment.failureReason != null) ...[
            const SizedBox(height: 8),
            Text(
              segment.failureReason!,
              style: const TextStyle(
                color: Color(0xFFE53935),
                fontSize: 11,
              ),
            ),
          ],

          // Tamamlanan segment butonları
          if (segment.isCompleted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // İndir butonu
                if (segment.videoUrl != null)
                  _DownloadButton(url: segment.videoUrl!, l10n: l10n),
                const SizedBox(width: 8),

                // Düzenleme butonu
                if (segment.canRequestEdit)
                  _EditButton(
                    onTap: () => _showEditDialog(context, ref, l10n),
                  )
                else if (segment.hasPendingEdit)
                  _EditPendingBadge(l10n: l10n),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${l10n.requestEditButton} — ${l10n.segmentNumber} ${segment.segmentNumber}',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 5,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.editPromptHint,
                  hintStyle:
                      const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.gold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final prompt = controller.text.trim();
                    if (prompt.isEmpty) return;
                    Navigator.pop(ctx);

                    try {
                      await ref
                          .read(customVideoDetailProvider(uuid).notifier)
                          .editSegment(
                            segmentId: segment.id,
                            editPrompt: prompt,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.editSubmitted),
                            backgroundColor: const Color(0xFF4CAF50),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                e.toString().replaceFirst('Exception: ', '')),
                            backgroundColor: const Color(0xFFE53935),
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    l10n.submitEdit,
                    style: const TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gold, Color(0xFFF5D97A)],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.download_rounded,
                color: AppColors.background, size: 16),
            const SizedBox(width: 4),
            Text(
              l10n.downloadVideo,
              style: const TextStyle(
                color: AppColors.background,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit Button ──────────────────────────────────────────────────────────────

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.edit_outlined,
                color: AppColors.gold, size: 16),
            const SizedBox(width: 4),
            Text(
              l10n.requestEditButton,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Edit Pending Badge ───────────────────────────────────────────────────────

class _EditPendingBadge extends StatelessWidget {
  final AppLocalizations l10n;

  const _EditPendingBadge({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5A623).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: const Color(0xFFF5A623).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hourglass_top_rounded,
              color: Color(0xFFF5A623), size: 14),
          const SizedBox(width: 4),
          Text(
            l10n.editPending,
            style: const TextStyle(
              color: Color(0xFFF5A623),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Segment Status Badge ─────────────────────────────────────────────────────

class _SegmentStatusBadge extends StatelessWidget {
  final CustomVideoStatus status;

  const _SegmentStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (label, color) = switch (status) {
      CustomVideoStatus.pending    => (l10n.requestPending,    const Color(0xFFF5A623)),
      CustomVideoStatus.processing => (l10n.requestProcessing, const Color(0xFF4A9EFF)),
      CustomVideoStatus.completed  => (l10n.requestCompleted,  const Color(0xFF4CAF50)),
      CustomVideoStatus.failed     => (l10n.requestFailed,     const Color(0xFFE53935)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Empty Segments ───────────────────────────────────────────────────────────

class _EmptySegments extends StatelessWidget {
  final String message;

  const _EmptySegments({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.1)),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
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