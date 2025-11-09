import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../api/auth_api.dart';
import '../../../../api/api_client.dart';
import '../../../../api/models/auth_models.dart';
import '../../../../api/models/user_models.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/auth_provider.dart';

enum EmailVerificationState {
  initial,
  loading,
  success,
  error,
}

class EmailVerificationStateData {
  final EmailVerificationState state;
  final String? errorMessage;
  final String? successMessage;
  final int? attemptsRemaining;

  const EmailVerificationStateData({
    required this.state,
    this.errorMessage,
    this.successMessage,
    this.attemptsRemaining,
  });

  EmailVerificationStateData copyWith({
    EmailVerificationState? state,
    String? errorMessage,
    String? successMessage,
    int? attemptsRemaining,
  }) {
    return EmailVerificationStateData(
      state: state ?? this.state,
      errorMessage: errorMessage,
      successMessage: successMessage ?? this.successMessage,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
    );
  }
}

class EmailVerificationController extends StateNotifier<EmailVerificationStateData> {
  final AuthApi _authApi;
  final ApiClient _apiClient;
  final AuthNotifier _authNotifier;

  EmailVerificationController(this._authApi, this._apiClient, this._authNotifier)
      : super(const EmailVerificationStateData(state: EmailVerificationState.initial));

  Future<void> verifyCode({required String email, required String code}) async {
    debugPrint('EMAIL_VERIFICATION: Verifying code for email: $email');
    state = state.copyWith(state: EmailVerificationState.loading);

    try {
      final isVerified = await _authApi.verifyCode(email, code);

      if (isVerified) {
        debugPrint('EMAIL_VERIFICATION: Code verified successfully!');
        
        state = state.copyWith(
          state: EmailVerificationState.success,
          successMessage: '¡Código verificado exitosamente! Ahora puedes iniciar sesión.',
        );
      } else {
        debugPrint('EMAIL_VERIFICATION: Code is incorrect');
        state = state.copyWith(
          state: EmailVerificationState.error,
          errorMessage: 'Código incorrecto. Verifica el código de 6 dígitos enviado a tu email.',
        );
      }
    } catch (e) {
      debugPrint('EMAIL_VERIFICATION VERIFY ERROR: $e');
      
      String errorMessage;
      if (e.toString().contains('Código inválido')) {
        errorMessage = 'Código inválido o expirado. Solicita un nuevo código.';
      } else if (e.toString().contains('404') || e.toString().contains('Email not found')) {
        errorMessage = 'Email no encontrado. Verifica que el email sea correcto.';
      } else {
        errorMessage = 'Error al verificar el código. Intenta de nuevo.';
      }

      state = state.copyWith(
        state: EmailVerificationState.error,
        errorMessage: errorMessage,
      );
    }
  }

  Future<void> resendVerification(String email) async {
    if (email.isEmpty) {
      state = state.copyWith(
        state: EmailVerificationState.error,
        errorMessage: 'Email no puede estar vacío',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      state = state.copyWith(
        state: EmailVerificationState.error,
        errorMessage: 'Por favor ingresa un email válido',
      );
      return;
    }

    debugPrint('EMAIL_VERIFICATION: Resending verification for email: $email');
    state = state.copyWith(state: EmailVerificationState.loading);

    try {
      await _authApi.sendLoginVerificationCode(email);
      debugPrint('EMAIL_VERIFICATION: Verification code resent successfully!');
      
      state = state.copyWith(
        state: EmailVerificationState.success,
        successMessage: '¡Código de verificación reenviado! Revisa tu email.',
      );
    } catch (e) {
      debugPrint('EMAIL_VERIFICATION ERROR: $e');
      debugPrint('Error Type: ${e.runtimeType}');
      
      String errorMessage;
      
      if (e is RateLimitException) {
        debugPrint('EMAIL_VERIFICATION: Rate limit exceeded');
        debugPrint('Blocked until: ${e.blockedUntil}');
        
        if (e.blockedUntil != null) {
          try {
            final blockedUntil = DateTime.parse(e.blockedUntil!);
            final now = DateTime.now();
            final difference = blockedUntil.difference(now);
            
            if (difference.inMinutes > 0) {
              errorMessage = 'Demasiados intentos. Bloqueado por ${difference.inMinutes} minutos.';
            } else {
              errorMessage = 'Demasiados intentos. Espera unos minutos antes de intentar de nuevo.';
            }
          } catch (_) {
            errorMessage = e.message;
          }
        } else {
          errorMessage = e.message;
        }
      } else {
        // Handle other types of errors
        String rawMessage = e.toString().replaceFirst('Exception: ', '');
        debugPrint('Processed Error Message: $rawMessage');
        
        if (rawMessage.contains('User not found') || rawMessage.contains('404')) {
          debugPrint('EMAIL_VERIFICATION: User not found');
          errorMessage = 'No se encontró una cuenta con este email. Verifica que esté correcto.';
        } else if (rawMessage.contains('already verified') || rawMessage.contains('already_verified')) {
          debugPrint('EMAIL_VERIFICATION: User already verified');
          errorMessage = 'Esta cuenta ya está verificada. Puedes iniciar sesión directamente.';
        } else if (rawMessage.contains('Connection') || rawMessage.contains('timeout')) {
          debugPrint('EMAIL_VERIFICATION: Connection issues');
          errorMessage = 'Error de conexión: No se puede conectar al servidor. Verifica que el backend esté ejecutándose.';
        } else {
          debugPrint('EMAIL_VERIFICATION: Unknown error');
          errorMessage = 'Error al reenviar el código: $rawMessage';
        }
      }
      
      debugPrint('Final Error Message: $errorMessage');
      
      state = state.copyWith(
        state: EmailVerificationState.error,
        errorMessage: errorMessage,
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String _getDefaultAvatarUrl(String name) {
    final encodedName = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encodedName&background=4ABDCA&color=fff&size=200';
  }

  void clearError() {
    if (state.state == EmailVerificationState.error) {
      state = state.copyWith(state: EmailVerificationState.initial, errorMessage: null);
    }
  }
}

final emailVerificationControllerProvider = StateNotifierProvider<EmailVerificationController, EmailVerificationStateData>((ref) {
  final authApi = ref.watch(authApiProvider);
  final apiClient = ref.watch(apiClientProvider);
  final authNotifier = ref.read(authProvider.notifier);
  
  return EmailVerificationController(authApi, apiClient, authNotifier);
});