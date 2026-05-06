// lib/features/templates/presentation/screens/template_swipe_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import 'package:asilov/core/constants/app_colors.dart';
import 'package:asilov/core/router/app_router.dart';
import 'package:asilov/features/auth/presentation/providers/auth_provider.dart';
import 'package:asilov/features/templates/domain/entities/template_entity.dart';
import 'package:asilov/features/templates/presentation/providers/template_provider.dart';
import 'package:asilov/l10n/app_localizations.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class TemplateSwipeScreen extends ConsumerStatefulWidget {
  final String initialUuid;

  const TemplateSwipeScreen({super.key, required this.initialUuid});

  @override
  ConsumerState<TemplateSwipeScreen> createState() =>
      _TemplateSwipeScreenState();
}

class _TemplateSwipeScreenState extends ConsumerState<TemplateSwipeScreen> {
  // ─── Sayfa Kontrolü ───────────────────────────────────────────────────────
  PageController? _pageController;
  int _currentIndex = 0;
  bool _isMuted = true;
  bool _hintVisible = true;

  /// templates ilk yüklendiğinde tek seferlik başlatma yapılır
  bool _didInit = false;

  // ─── Video Yönetimi ───────────────────────────────────────────────────────
  /// index → controller haritası
  final Map<int, VideoPlayerController> _controllers = {};

  /// initialize + play başarıyla tamamlanan slide indisleri
  final Set<int> _readyIndices = {};

  List<TemplateEntity> _templates = [];

  /// Mevcut sayfanın önünde yüklenecek slide sayısı
  static const int _preloadAhead = 2;

  /// Mevcut sayfanın arkasında yüklenecek slide sayısı
  static const int _preloadBehind = 1;

  /// Bu uzaklıktaki slide'ların controller'ı dispose edilir
  static const int _disposeThreshold = 4;

  // ─── Yaşam Döngüsü ───────────────────────────────────────────────────────
  @override
  void dispose() {
    _pageController?.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Template Başlatma ────────────────────────────────────────────────────

  /// Template listesi ilk kez yüklendiğinde PageController'ı doğru
  /// konumla oluşturur, video penceresini açar ve hint timer'ını başlatır.
  void _initWithTemplates(List<TemplateEntity> templates) {
    if (_didInit) return;
    _didInit = true;
    _templates = templates;

    final startIndex =
        templates.indexWhere((t) => t.uuid == widget.initialUuid);
    _currentIndex = startIndex >= 0 ? startIndex : 0;

    // initialPage ile PageView'ı doğru konumdan başlatıyoruz —
    // böylece hiçbir animasyon / flash olmadan doğru slide görünür.
    _pageController = PageController(initialPage: _currentIndex);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _manageWindow(_currentIndex);

      // 3 saniye sonra hint'i gizle
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _hintVisible = false);
      });
    });
  }

  // ─── Video Yönetimi ───────────────────────────────────────────────────────

  /// Portrait öncelikli video URL'si; yoksa landscape döner.
  String? _getBestVideoUrl(TemplateEntity template) {
    return template.portraitVideoUrl ?? template.landscapeVideoUrl;
  }

  /// Verilen index için VideoPlayerController oluşturur, initialize eder
  /// ve gerekirse oynatmaya başlar.
  Future<void> _initController(int index) async {
    if (!mounted) return;
    if (_controllers.containsKey(index)) return;
    if (index < 0 || index >= _templates.length) return;

    final url = _getBestVideoUrl(_templates[index]);
    debugPrint('🎬 VIDEO URL [$index]: $url');
    if (url == null || url.isEmpty) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controllers[index] = controller;

    try {
      await controller.initialize();

      // Widget ağaçtan kaldırılmışsa temizle
      if (!mounted) {
        controller.dispose();
        _controllers.remove(index);
        return;
      }

      await controller.setLooping(true);

      // Şu an aktif slide ise sesi ayarla ve oynat
      if (index == _currentIndex) {
        await controller.setVolume(_isMuted ? 0.0 : 1.0);
        await controller.play();
      }

      // Hazır listesine ekle → build yeniden çalışır, _VideoFadeIn görünür
      if (mounted) setState(() => _readyIndices.add(index));
    } catch (_) {
      // Başarısız olursa haritadan kaldır, tekrar deneme yapılabilir
      _controllers.remove(index);
    }
  }

  /// Controller'ı durdurur, dispose eder ve haritadan çıkarır.
  void _disposeController(int index) {
    final c = _controllers.remove(index);
    _readyIndices.remove(index);
    c?.dispose();
  }

  /// Aktif pencere içindeki slide'ları preload eder,
  /// uzak olanların controller'larını serbest bırakır.
  void _manageWindow(int center) {
    for (int i = 0; i < _templates.length; i++) {
      final dist = i - center;
      if (dist >= -_preloadBehind && dist <= _preloadAhead) {
        _initController(i);
      } else if (dist.abs() > _disposeThreshold) {
        _disposeController(i);
      }
    }
  }

  // ─── Sayfa Değişimi ───────────────────────────────────────────────────────
  void _onPageChanged(int index) {
    final prev = _currentIndex;
    _currentIndex = index;

    // Önceki slide'ı durdur ve başa sar
    _controllers[prev]?.pause();
    _controllers[prev]?.seekTo(Duration.zero);

    // Yeni slide'ı oynat (controller zaten initialize edilmişse)
    final c = _controllers[index];
    if (c != null && c.value.isInitialized) {
      c.setVolume(_isMuted ? 0.0 : 1.0);
      c.play();
    }

    _manageWindow(index);

    if (mounted) {
      setState(() => _hintVisible = false);
    }
  }

  // ─── Ses Kontrolü ─────────────────────────────────────────────────────────
  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _controllers[_currentIndex]?.setVolume(_isMuted ? 0.0 : 1.0);
  }

  // ─── Başlık Yardımcı ──────────────────────────────────────────────────────
  /// template_entity.dart implementasyonuna göre düzenle:
  ///   - title String ise → template.title
  ///   - title Map<String,String> ise → template.titleMap[locale] ?? template.titleMap['en'] ?? ''
  ///   - getTitle(locale) metodu varsa → template.getTitle(locale)
  String _localizedTitle(TemplateEntity template, String locale) {
    return template.title.localized(locale);
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templateListProvider);
    final authState = ref.watch(authProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: Colors.black,
      body: templatesAsync.when(
        loading: () => const _LoadingView(),
        error: (error, _) => _ErrorView(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.read(templateListProvider.notifier).refresh(),
          l10n: l10n,
        ),
        data: (templates) {
          _initWithTemplates(templates);

          if (templates.isEmpty || _pageController == null) {
            return Center(
              child: Text(
                l10n.noTemplates,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return _buildSwipeView(context, templates, authState, l10n, locale);
        },
      ),
    );
  }

  // ─── Swipe Görünümü ───────────────────────────────────────────────────────
  Widget _buildSwipeView(
    BuildContext context,
    List<TemplateEntity> templates,
    AuthState authState,
    AppLocalizations l10n,
    String locale,
  ) {
    return Stack(
      children: [
        // ── Dikey PageView ──────────────────────────────────────────────────
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: templates.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) => _buildSlide(
            context,
            index,
            templates[index],
            authState,
            l10n,
            locale,
          ),
        ),

        // ── Üst Kontroller: Geri + Sayaç ────────────────────────────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Geri Butonu
                _GlassCircleButton(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),

                // Sayaç
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${templates.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Ses Butonu (sol alt) ─────────────────────────────────────────────
        SafeArea(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 38),
              child: _GlassCircleButton(
                onTap: _toggleMute,
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // ── Swipe Hint ──────────────────────────────────────────────────────
        if (_hintVisible)
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _hintVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 600),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _BounceArrow(),
                    const SizedBox(height: 6),
                    Text(
                      l10n.swipeHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─── Tek Slide ────────────────────────────────────────────────────────────
  Widget _buildSlide(
    BuildContext context,
    int index,
    TemplateEntity template,
    AuthState authState,
    AppLocalizations l10n,
    String locale,
  ) {
    final controller = _controllers[index];
    final posterUrl = template.posterUrl;
    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final title = _localizedTitle(template, locale);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── 1. Poster: her zaman arka planda, anında görünür ────────────────
        // FIX: poster CSS background gibi çalışır — video hazır olana kadar
        //      siyah ekran görmemek için bu katman her zaman vardır.
        if (posterUrl != null && posterUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: posterUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFF111111)),
            errorWidget: (_, __, ___) =>
                Container(color: const Color(0xFF111111)),
          )
        else
          Container(color: const Color(0xFF111111)),

        // ── 2. Video: hazır olduğunda fade-in ile posterın üstüne geçer ─────
        // FIX: _VideoFadeIn opacity 0'dan başlar, 300ms'de 1'e ulaşır.
        //      Bu geçiş sırasında poster altta görünür — siyah flash yok.
        if (controller != null && _readyIndices.contains(index))
          _VideoFadeIn(controller: controller),

        // ── 3. Alt Gradient: başlık ve butonlar okunabilsin ─────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.45,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xD9000000), // 85% siyah
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // ── 4. Başlık ────────────────────────────────────────────────────────
        if (title.isNotEmpty)
          Positioned(
            bottom: 108,
            left: 16,
            right: 80,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.4,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black87,
                  ),
                ],
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // ── 5. Token Maliyeti ────────────────────────────────────────────────
        Positioned(
          bottom: 82,
          left: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.toll_outlined, color: AppColors.gold, size: 14),
              const SizedBox(width: 4),
              Text(
                '${template.tokenCost} ${l10n.tokens}',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // ── 6. Aksiyon Butonu (sağ alt) ──────────────────────────────────────
        Positioned(
          bottom: 36,
          right: 16,
          child: _ActionButton(
            label: isAuthenticated ? l10n.useTemplate : l10n.loginToUse,
            onTap: () {
              if (isAuthenticated) {
                // TODO: Şablon oluşturma ekranı hazır olduğunda güncelle:
                // context.push(AppRoutes.createTemplateGeneration, extra: template);
                context.push(AppRoutes.createImage);
              } else {
                context.push(AppRoutes.login);
              }
            },
          ),
        ),
      ],
    );
  }
}

// ─── Video Fade-In Widget ─────────────────────────────────────────────────────
// Bağımsız StatefulWidget olarak tanımlanır; initState'te animasyon başlar.
// Bu sayede her slide'ın videosu kendi fade-in sürecini bağımsız yönetir.

class _VideoFadeIn extends StatefulWidget {
  final VideoPlayerController controller;

  const _VideoFadeIn({required this.controller});

  @override
  State<_VideoFadeIn> createState() => _VideoFadeInState();
}

class _VideoFadeInState extends State<_VideoFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn),
    );
    // Widget ağaca girdiği anda fade-in başlar
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FittedBox + SizedBox kombinasyonu VideoPlayer'ı tam ekrana yayar
    // ve video boyutu ne olursa olsun cover davranışı sağlar.
    return FadeTransition(
      opacity: _opacity,
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: widget.controller.value.size.width,
            height: widget.controller.value.size.height,
            child: VideoPlayer(widget.controller),
          ),
        ),
      ),
    );
  }
}

// ─── Glass Circle Button ──────────────────────────────────────────────────────

class _GlassCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GlassCircleButton({
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.gold, Color(0xFFF5D97A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.5),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0B0B0B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ─── Bounce Arrow (Swipe Hint) ────────────────────────────────────────────────

class _BounceArrow extends StatefulWidget {
  const _BounceArrow();

  @override
  State<_BounceArrow> createState() => _BounceArrowState();
}

class _BounceArrowState extends State<_BounceArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _offset = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _offset.value),
        child: child,
      ),
      child: const Icon(
        Icons.keyboard_arrow_up_rounded,
        color: Colors.white70,
        size: 32,
      ),
    );
  }
}

// ─── Loading View ─────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.gold,
        strokeWidth: 2,
      ),
    );
  }
}

// ─── Error View ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final AppLocalizations l10n;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                color: AppColors.textDisabled, size: 40),
            const SizedBox(height: 16),
            Text(
              message,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
