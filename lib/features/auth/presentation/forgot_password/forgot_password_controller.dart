import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../api/auth_api.dart';
import '../../../../api/models/auth_models.dart';
import '../../../../providers/api_providers.dart';

enum ForgotPasswordState {
  initial,
  loading,
  success,
  error,
}

class ForgotPasswordStateData {
  final ForgotPasswordState state;
  final String? errorMessage;
  final String? email;

  const ForgotPasswordStateData({
    required this.state,
    this.errorMessage,
    this.email,
  });

  ForgotPasswordStateData copyWith({
    ForgotPasswordState? state,
    String? errorMessage,
    String? email,
  }) {
    return ForgotPasswordStateData(
      state: state ?? this.state,
      errorMessage: errorMessage,
      email: email ?? this.email,
    );
  }
}

class ForgotPasswordController extends StateNotifier<ForgotPasswordStateData> {
  final AuthApi _authApi;

  ForgotPasswordController(this._authApi)
      : super(const ForgotPasswordStateData(state: ForgotPasswordState.initial));

  Future<void> sendResetCode(String email) async {
    if (email.isEmpty) {
      state = state.copyWith(
        state: ForgotPasswordState.error,
        errorMessage: 'Por favor ingresa tu email',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      state = state.copyWith(
        state: ForgotPasswordState.error,
        errorMessage: 'Por favor ingresa un email válido',
      );
      return;
    }

    debugPrint('FORGOT_PASSWORD: Sending reset code for email: $email');
    state = state.copyWith(state: ForgotPasswordState.loading);

    try {
      await _authApi.forgotPassword(email);
      debugPrint('FORGOT_PASSWORD: Reset code sent successfully!');
      
      state = state.copyWith(
        state: ForgotPasswordState.success,
        email: email,
      );
    } catch (e) {
      debugPrint('FORGOT_PASSWORD ERROR: $e');
      debugPrint('Error Type: ${e.runtimeType}');
      
      String errorMessage;
      
      if (e is RateLimitException) {
        debugPrint('FORGOT_PASSWORD: Rate limit exceeded');
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
        
        if (rawMessage.contains('Email not found') || rawMessage.contains('404')) {
          debugPrint('FORGOT_PASSWORD: Email not found');
          // Por seguridad, no revelamos si el email existe o no
          errorMessage = 'Si el email existe en nuestro sistema, recibirás un código de recuperación.';
        } else if (rawMessage.contains('Connection') || rawMessage.contains('timeout')) {
          debugPrint('FORGOT_PASSWORD: Connection issues');
          errorMessage = 'Error de conexión: No se puede conectar al servidor. Verifica que el backend esté ejecutándose.';
        } else {
          debugPrint('FORGOT_PASSWORD: Unknown error');
          errorMessage = 'Error al enviar el código de recuperación: $rawMessage';
        }
      }
      
      debugPrint('Final Error Message: $errorMessage');
      
      state = state.copyWith(
        state: ForgotPasswordState.error,
        errorMessage: errorMessage,
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void clearError() {
    if (state.state == ForgotPasswordState.error) {
      state = state.copyWith(state: ForgotPasswordState.initial, errorMessage: null);
    }
  }
}

final forgotPasswordControllerProvider = StateNotifierProvider<ForgotPasswordController, ForgotPasswordStateData>((ref) {
  final authApi = ref.watch(authApiProvider);
  
  return ForgotPasswordController(authApi);
});