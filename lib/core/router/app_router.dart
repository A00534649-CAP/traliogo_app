import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/presentation/login/login_page.dart';
import '../../features/auth/presentation/signup/signup_page.dart';
import '../../features/auth/presentation/verify/verify_identity_page.dart';
import '../../features/auth/presentation/email_verification/email_verification_page.dart';
import '../../features/auth/presentation/login_verification/login_verification_page.dart';
import '../../features/auth/presentation/forgot_password/forgot_password_page.dart';
import '../../features/auth/presentation/verify_reset_code/verify_reset_code_page.dart';
import '../../features/auth/presentation/reset_password/reset_password_page.dart';
import '../../features/home/home_page.dart';
import '../../features/objects/presentation/camera/camera_objects_page.dart';
import '../../features/objects/presentation/history/objects_history_page.dart';
import '../../features/translations/presentation/manual/manual_translation_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      final isAuthenticated = authState.isAuthenticated;
      final isVerified = authState.isVerified;

      // If on splash, let it handle navigation
      if (path == '/') {
        return null;
      }

      // If not authenticated and trying to access protected routes
      if (!isAuthenticated && (path == '/home' || path == '/verify')) {
        return '/login';
      }
      
      // Allow access to verification and password reset pages without authentication
      if (path.startsWith('/email-verification') || 
          path.startsWith('/login-verification') ||
          path.startsWith('/forgot-password') ||
          path.startsWith('/verify-reset-code') ||
          path.startsWith('/reset-password')) {
        return null;
      }

      // If authenticated but not verified and not on verify page
      if (isAuthenticated && !isVerified && path != '/verify') {
        return '/verify';
      }

      // If authenticated and verified but on auth pages
      if (isAuthenticated && isVerified && (path == '/login' || path == '/signup' || path == '/verify')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/email-verification',
        name: 'email_verification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return EmailVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: '/login-verification',
        name: 'login_verification',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return LoginVerificationPage(email: email);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-reset-code',
        name: 'verify_reset_code',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return VerifyResetCodePage(email: email);
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset_password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final code = state.uri.queryParameters['code'];
          final token = state.uri.queryParameters['token'];
          return ResetPasswordPage(email: email, code: code, token: token);
        },
      ),
      GoRoute(
        path: '/verify',
        name: 'verify',
        builder: (context, state) => const VerifyIdentityPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/objects',
        name: 'objects',
        builder: (context, state) => const CameraObjectsPage(),
      ),
      GoRoute(
        path: '/objects/history',
        name: 'objects_history',
        builder: (context, state) => const ObjectsHistoryPage(),
      ),
      GoRoute(
        path: '/translations/manual',
        name: 'manual_translation',
        builder: (context, state) => const ManualTranslationPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri.path}" does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});