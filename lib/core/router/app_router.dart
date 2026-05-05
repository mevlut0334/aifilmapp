// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';

// ─── Route Sabitleri ──────────────────────────────────────────────────────────

abstract class AppRoutes {
  static const splash         = '/';
  static const login          = '/login';
  static const register       = '/register';
  static const forgotPassword = '/forgot-password';
  static const resetPassword  = '/reset-password';
  static const home           = '/home';
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

    final isAuthPage = location == AppRoutes.login ||
                       location == AppRoutes.register ||
                       location == AppRoutes.forgotPassword ||
                       location == AppRoutes.resetPassword;

    switch (authState.status) {
      case AuthStatus.initial:
        return location == AppRoutes.splash ? null : AppRoutes.splash;

      case AuthStatus.authenticated:
        if (isAuthPage || location == AppRoutes.splash) {
          return AppRoutes.home;
        }
        return null;

      case AuthStatus.unauthenticated:
        return isAuthPage ? null : AppRoutes.login;
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
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
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
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
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