import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/generation/presentation/screens/create_template_generation_screen.dart';
import '../../features/generation/presentation/screens/generation_list_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/templates/presentation/screens/template_swipe_screen.dart';
import '../widgets/app_shell.dart';

// ─── Route Sabitleri ──────────────────────────────────────────────────────────

abstract class AppRoutes {
  static const splash          = '/';
  static const login           = '/login';
  static const register        = '/register';
  static const forgotPassword  = '/forgot-password';
  static const resetPassword   = '/reset-password';

  // Shell rotaları (bottom nav)
  static const home            = '/home';
  static const myTemplates     = '/my-templates';
  static const myImages        = '/my-images';
  static const myVideos        = '/my-videos';

  // Giriş gerektiren rotalar
  static const createImage              = '/create-image';
  static const createVideo              = '/create-video';
  static const createTemplateGeneration = '/create-template-generation';

  // Genel rotalar
  static const templateSwipe   = '/template-swipe';
  static const packages        = '/packages';
  static const about           = '/about';
  static const privacy         = '/privacy';
  static const terms           = '/terms';
}

// ─── Korumalı rotalar (giriş zorunlu) ────────────────────────────────────────

const _protectedRoutes = [
  AppRoutes.myTemplates,
  AppRoutes.myImages,
  AppRoutes.myVideos,
  AppRoutes.createImage,
  AppRoutes.createVideo,
  AppRoutes.createTemplateGeneration,
];

// ─── Bottom nav index hesaplama ───────────────────────────────────────────────

int _shellIndex(String location) {
  if (location.startsWith(AppRoutes.myTemplates)) return 1;
  if (location.startsWith(AppRoutes.myImages))    return 3;
  if (location.startsWith(AppRoutes.myVideos))    return 4;
  return 0;
}

// ─── RouterNotifier ───────────────────────────────────────────────────────────

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authProvider);
    final location  = state.matchedLocation;

    final isAuthPage = location == AppRoutes.login      ||
                       location == AppRoutes.register   ||
                       location == AppRoutes.forgotPassword ||
                       location == AppRoutes.resetPassword;

    final isProtected = _protectedRoutes.any(
      (r) => location.startsWith(r),
    );

    switch (authState.status) {
      case AuthStatus.initial:
        return location == AppRoutes.splash ? null : AppRoutes.splash;

      case AuthStatus.authenticated:
        if (isAuthPage || location == AppRoutes.splash) {
          return AppRoutes.home;
        }
        return null;

      case AuthStatus.unauthenticated:
        if (isAuthPage) return null;
        if (isProtected) return AppRoutes.login;
        if (location == AppRoutes.splash) return AppRoutes.home;
        return null; // Ana sayfa ve swipe herkese açık
    }
  }
}

// ─── Router Provider ──────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [

      // Splash
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth rotaları
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Template swipe (shell dışı — tam ekran, giriş gerektirmez)
      GoRoute(
        path: '${AppRoutes.templateSwipe}/:uuid',
        builder: (context, state) {
          final uuid = state.pathParameters['uuid']!;
          return TemplateSwipeScreen(initialUuid: uuid);
        },
      ),

      // Create rotaları (shell dışı — tam ekran, giriş zorunlu)
      GoRoute(
        path: AppRoutes.createImage,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Görsel Oluştur'),
      ),
      GoRoute(
        path: AppRoutes.createVideo,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Video Oluştur'),
      ),

      // Şablon ile talep oluşturma (shell dışı — tam ekran, giriş zorunlu)
      GoRoute(
        path: '${AppRoutes.createTemplateGeneration}/:templateUuid',
        builder: (context, state) {
          final templateUuid = state.pathParameters['templateUuid']!;
          return CreateTemplateGenerationScreen(templateUuid: templateUuid);
        },
      ),

      // Drawer rotaları (shell dışı)
      GoRoute(
        path: AppRoutes.packages,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Paketler'),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Hakkımızda'),
      ),
      GoRoute(
        path: AppRoutes.privacy,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Gizlilik Politikası'),
      ),
      GoRoute(
        path: AppRoutes.terms,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Kullanım Şartları'),
      ),

      // ── Shell (Bottom Nav) ────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AppShell(
          currentIndex: _shellIndex(state.matchedLocation),
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),

          // ✅ Talep listesi — GenerationListScreen'e bağlandı
          GoRoute(
            path: AppRoutes.myTemplates,
            builder: (context, state) => const GenerationListScreen(),
          ),

          GoRoute(
            path: AppRoutes.myImages,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Görsellerim'),
          ),
          GoRoute(
            path: AppRoutes.myVideos,
            builder: (context, state) =>
                const _PlaceholderScreen(title: 'Videolarım'),
          ),
        ],
      ),
    ],
  );
});

// ─── Splash Screen ────────────────────────────────────────────────────────────

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D0D0D),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

// ─── Placeholder Screen (geçici) ─────────────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}