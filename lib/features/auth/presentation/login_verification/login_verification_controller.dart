import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../api/auth_api.dart';
import '../../../../api/api_client.dart';
import '../../../../api/models/auth_models.dart';
import '../../../../api/models/user_models.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/firebase_auth_service.dart';

enum LoginVerificationState {
  initial,
  loading,
  success,
  error,
}

class LoginVerificationStateData {
  final LoginVerificationState state;
  final String? errorMessage;
  final bool canResend;
  final int remainingAttempts;
  final int? blockedTimeRemaining;

  const LoginVerificationStateData({
    required this.state,
    this.errorMessage,
    this.canResend = true,
    this.remainingAttempts = 3,
    this.blockedTimeRemaining,
  });

  LoginVerificationStateData copyWith({
    LoginVerificationState? state,
    String? errorMessage,
    bool? canResend,
    int? remainingAttempts,
    int? blockedTimeRemaining,
  }) {
    return LoginVerificationStateData(
      state: state ?? this.state,
      errorMessage: errorMessage,
      canResend: canResend ?? this.canResend,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
      blockedTimeRemaining: blockedTimeRemaining,
    );
  }
}

class LoginVerificationController extends StateNotifier<LoginVerificationStateData> {
  final AuthApi _authApi;
  final ApiClient _apiClient;
  final AuthNotifier _authNotifier;
  final FirebaseAuthService _firebaseAuthService;

  LoginVerificationController(this._authApi, this._apiClient, this._authNotifier, this._firebaseAuthService)
      : super(const LoginVerificationStateData(state: LoginVerificationState.initial));

  /// Verify 6-digit code and complete login if correct
  Future<void> verifyCodeAndLogin({
    required String email,
    required String code,
  }) async {
    debugPrint('LOGIN VERIFICATION: Verifying code for: $email');
    state = state.copyWith(state: LoginVerificationState.loading);

    try {
      // Use the complete login endpoint that verifies code and completes login in one step
      debugPrint('LOGIN VERIFICATION: Completing login with verification code...');
      final loginResponse = await _authApi.completeLogin(email, code);
      
      debugPrint('LOGIN VERIFICATION: Login completed successfully!');
      debugPrint('User ID: ${loginResponse.userId}');
      debugPrint('Access Token: ${loginResponse.accessToken.substring(0, 20)}...');

      // Configure API client with token
      _apiClient.setAccessToken(loginResponse.accessToken);
      debugPrint('LOGIN VERIFICATION: ApiClient configured with access token');

      // Create user object
      final userName = email.split('@')[0];
      final user = UserOut(
        id: loginResponse.userId,
        email: email,
        displayName: userName,
        avatarUrl: _getDefaultAvatarUrl(userName),
        role: 'client',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Update auth state
      _authNotifier.setAuthData(
        accessToken: loginResponse.accessToken,
        user: user,
        isVerified: true,
      );
      debugPrint('LOGIN VERIFICATION: User authenticated and stored');

      state = state.copyWith(state: LoginVerificationState.success);

    } catch (e) {
      debugPrint('LOGIN VERIFICATION ERROR: $e');

      String errorMessage;
      if (e.toString().contains('404') || e.toString().contains('Email not found')) {
        errorMessage = 'Email no encontrado. Verifica que el email sea correcto.';
      } else if (e.toString().contains('429') || e.toString().contains('Too Many Requests')) {
        errorMessage = 'Demasiados intentos. Espera antes de intentar de nuevo.';
      } else if (e.toString().contains('Connection') || e.toString().contains('timeout')) {
        errorMessage = 'Error de conexión. Verifica tu conexión a internet.';
      } else {
        errorMessage = 'Error al verificar el email. Intenta de nuevo.';
      }

      state = state.copyWith(
        state: LoginVerificationState.error,
        errorMessage: errorMessage,
      );
    }
  }

  /// Send login verification code using /api/v1/auth/send-verification-email
  Future<void> sendLoginVerificationCode({required String email}) async {
    debugPrint('LOGIN VERIFICATION: Sending verification code for email: $email');

    try {
      // Use the new login verification endpoint
      await _authApi.sendLoginVerificationCode(email);
      
      debugPrint('LOGIN VERIFICATION: Verification code sent successfully');
      
      // Reset state
      state = state.copyWith(
        state: LoginVerificationState.initial,
        errorMessage: null,
        remainingAttempts: state.remainingAttempts - 1,
      );

    } catch (e) {
      debugPrint('LOGIN VERIFICATION SEND ERROR: $e');

      String errorMessage;
      if (e is RateLimitException) {
        if (e.blockedUntil != null) {
          try {
            final blockedUntil = DateTime.parse(e.blockedUntil!);
            final now = DateTime.now();
            final difference = blockedUntil.difference(now);
            
            if (difference.inMinutes > 0) {
              errorMessage = 'Demasiados intentos. Bloqueado por ${difference.inMinutes} minutos.';
              state = state.copyWith(
                state: LoginVerificationState.error,
                errorMessage: errorMessage,
                canResend: false,
                blockedTimeRemaining: difference.inMinutes,
              );
              return;
            }
          } catch (_) {
            // Continue with generic message
          }
        }
        errorMessage = e.message;
      } else {
        errorMessage = 'Error al enviar código de verificación. Intenta de nuevo.';
      }

      state = state.copyWith(
        state: LoginVerificationState.error,
        errorMessage: errorMessage,
      );
    }
  }

  String _getDefaultAvatarUrl(String name) {
    final encodedName = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encodedName&background=4ABDCA&color=fff&size=200';
  }

  int? _extractBlockedMinutes(String errorMessage) {
    // Extract blocked minutes from error message if available
    final regex = RegExp(r'(\d+)\s*minut');
    final match = regex.firstMatch(errorMessage);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  void clearError() {
    if (state.state == LoginVerificationState.error) {
      state = state.copyWith(
        state: LoginVerificationState.initial,
        errorMessage: null,
      );
    }
  }
}

final loginVerificationControllerProvider = StateNotifierProvider<LoginVerificationController, LoginVerificationStateData>((ref) {
  final authApi = ref.watch(authApiProvider);
  final apiClient = ref.watch(apiClientProvider);
  final authNotifier = ref.read(authProvider.notifier);
  final firebaseAuthService = FirebaseAuthService();
  
  return LoginVerificationController(authApi, apiClient, authNotifier, firebaseAuthService);
});