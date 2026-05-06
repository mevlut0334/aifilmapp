import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:asilov/core/constants/app_colors.dart';
import 'package:asilov/core/router/app_router.dart';
import 'package:asilov/features/home/data/models/slider_model.dart';
import 'package:asilov/features/home/presentation/providers/slider_provider.dart';
import 'package:asilov/features/templates/domain/entities/template_entity.dart';
import 'package:asilov/features/templates/presentation/providers/template_provider.dart';
import 'package:asilov/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _HeroSlider()),
        SliverToBoxAdapter(child: _NavCards()),
        SliverToBoxAdapter(child: _SectionTitle()),
        _TemplateGrid(),
        SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// ─── Hero Slider ──────────────────────────────────────────────────────────────

class _HeroSlider extends ConsumerStatefulWidget {
  const _HeroSlider();

  @override
  ConsumerState<_HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends ConsumerState<_HeroSlider> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _current = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer(int count) {
    if (count <= 1) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final next = (_current + 1) % count;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final slidersAsync = ref.watch(sliderProvider);

    return slidersAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
              color: AppColors.gold, strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (sliders) {
        if (sliders.isEmpty) return const SizedBox.shrink();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_timer == null) _startTimer(sliders.length);
        });

        final locale = Localizations.localeOf(context).languageCode;

        return AspectRatio(
          aspectRatio: 16 / 7,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: sliders.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, i) =>
                    _SliderItem(slider: sliders[i], locale: locale),
              ),
              if (sliders.length > 1)
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      sliders.length,
                      (i) => GestureDetector(
                        onTap: () => _controller.animateToPage(
                          i,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _current == i ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _current == i
                                ? AppColors.gold
                                : Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
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

class _SliderItem extends StatelessWidget {
  final SliderModel slider;
  final String locale;

  const _SliderItem({required this.slider, required this.locale});

  // ✅ FIX: url_launcher ile linki açan yardımcı metod
  Future<void> _launchLink() async {
    final link = slider.buttonLink;
    if (link == null) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: slider.imageUrl,
          fit: BoxFit.cover,
          color: Colors.black.withValues(alpha: 0.3),
          colorBlendMode: BlendMode.darken,
          placeholder: (_, __) => Container(color: AppColors.surface),
          errorWidget: (_, __, ___) => Container(color: AppColors.surface),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 80,
          bottom: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                slider.getTitle(locale),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (slider.getDescription(locale).isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  slider.getDescription(locale),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              // ✅ FIX: GestureDetector eklendi
              if (slider.buttonLink != null &&
                  slider.getButtonText(locale) != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _launchLink,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.gold, Color(0xFFF5D97A)],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      slider.getButtonText(locale)!,
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Nav Cards ────────────────────────────────────────────────────────────────

class _NavCards extends StatelessWidget {
  const _NavCards();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 4),
      child: Row(
        children: [
          Expanded(
            child: _NavCard(
              label: l10n.createImage,
              icon: _imageIcon(),
              onTap: () => context.push(AppRoutes.createImage),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _NavCard(
              label: l10n.createVideo,
              icon: _videoIcon(),
              onTap: () => context.push(AppRoutes.createVideo),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageIcon() => SizedBox(
        width: 48,
        height: 48,
        child: CustomPaint(painter: _ImageIconPainter()),
      );

  Widget _videoIcon() => SizedBox(
        width: 48,
        height: 48,
        child: CustomPaint(painter: _VideoIconPainter()),
      );
}

class _NavCard extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _NavCard({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              icon,
              const SizedBox(height: 14),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Icon Painters ────────────────────────────────────────────────────────────

class _ImageIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.width / 56;

    final rrect = RRect.fromLTRBR(
        4 * s, 8 * s, 52 * s, 44 * s, Radius.circular(4 * s));
    canvas.drawRRect(rrect, paint);

    final mountain = Path()
      ..moveTo(4 * s, 34 * s)
      ..lineTo(16 * s, 20 * s)
      ..lineTo(26 * s, 30 * s)
      ..lineTo(34 * s, 22 * s)
      ..lineTo(52 * s, 34 * s);
    canvas.drawPath(mountain, paint);

    canvas.drawCircle(Offset(40 * s, 18 * s), 5 * s, paint);

    final sparkPaint = Paint()
      ..color = const Color(0xFFF5D97A)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (final cx in [10.0, 28.0, 46.0]) {
      canvas.drawLine(
          Offset(cx * s, 48 * s), Offset(cx * s, 52 * s), sparkPaint);
      canvas.drawLine(
          Offset((cx - 2) * s, 50 * s),
          Offset((cx + 2) * s, 50 * s),
          sparkPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _VideoIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.width / 56;

    canvas.drawRRect(
        RRect.fromLTRBR(
            4 * s, 16 * s, 52 * s, 50 * s, Radius.circular(4 * s)),
        paint);

    canvas.drawRRect(
        RRect.fromLTRBR(
            4 * s, 8 * s, 52 * s, 18 * s, Radius.circular(3 * s)),
        paint);

    for (final x in [14.0, 24.0, 34.0, 44.0]) {
      canvas.drawLine(
          Offset(x * s, 8 * s), Offset((x - 4) * s, 18 * s), paint);
    }

    final trianglePaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    final triangle = Path()
      ..moveTo(22 * s, 26 * s)
      ..lineTo(22 * s, 40 * s)
      ..lineTo(36 * s, 33 * s)
      ..close();
    canvas.drawPath(triangle, trianglePaint);
    canvas.drawPath(triangle, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
      child: Text(
        l10n.featuredTemplates,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Template Grid ────────────────────────────────────────────────────────────

class _TemplateGrid extends ConsumerWidget {
  const _TemplateGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templateListProvider);
    final l10n = AppLocalizations.of(context)!;

    return templatesAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
                color: AppColors.gold, strokeWidth: 2),
          ),
        ),
      ),
      // ✅ FIX: error state artık retry butonu gösteriyor
      error: (error, __) => SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_outlined,
                    color: AppColors.textDisabled, size: 32),
                const SizedBox(height: 8),
                Text(
                  error.toString().replaceFirst('Exception: ', ''),
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      ref.read(templateListProvider.notifier).refresh(),
                  child: Text(
                    l10n.retry,
                    style: const TextStyle(color: AppColors.gold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (templates) {
        if (templates.isEmpty) {
          return SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  l10n.noTemplates,
                  style:
                      const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childCount: templates.length,
            itemBuilder: (context, i) =>
                _TemplateCard(template: templates[i]),
          ),
        );
      },
    );
  }
}

// ─── Template Card ────────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final TemplateEntity template;

  const _TemplateCard({required this.template});

  String get _orientation {
    if (template.portraitVideoUrl != null) return 'portrait';
    if (template.landscapeVideoUrl != null) return 'landscape';
    return 'square';
  }

  double get _aspectRatio {
    switch (_orientation) {
      case 'portrait':
        return 9 / 16;
      case 'landscape':
        return 16 / 9;
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.push('${AppRoutes.templateSwipe}/${template.uuid}'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: _aspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (template.posterUrl != null)
                CachedNetworkImage(
                  imageUrl: template.posterUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) =>
                      Container(color: AppColors.surface),
                  errorWidget: (_, __, ___) =>
                      Container(color: AppColors.surface),
                )
              else
                Container(color: AppColors.surface),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.toll_outlined,
                          color: AppColors.gold, size: 11),
                      const SizedBox(width: 3),
                      Text(
                        '${template.tokenCost}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}