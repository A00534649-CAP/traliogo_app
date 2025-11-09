import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../api/auth_api.dart';
import '../../../../providers/api_providers.dart';

enum ResetPasswordState {
  initial,
  loading,
  success,
  error,
}

class ResetPasswordStateData {
  final ResetPasswordState state;
  final String? errorMessage;

  const ResetPasswordStateData({
    required this.state,
    this.errorMessage,
  });

  ResetPasswordStateData copyWith({
    ResetPasswordState? state,
    String? errorMessage,
  }) {
    return ResetPasswordStateData(
      state: state ?? this.state,
      errorMessage: errorMessage,
    );
  }
}

class ResetPasswordController extends StateNotifier<ResetPasswordStateData> {
  final AuthApi _authApi;

  ResetPasswordController(this._authApi)
      : super(const ResetPasswordStateData(state: ResetPasswordState.initial));

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    debugPrint('RESET_PASSWORD: Completing password reset for email: $email');
    state = state.copyWith(state: ResetPasswordState.loading);

    try {
      // Use the standard reset password endpoint
      debugPrint('RESET_PASSWORD: Using reset password endpoint...');
      final isReset = await _authApi.resetPassword(email, code, newPassword);
      
      if (isReset) {
        debugPrint('RESET_PASSWORD: Password reset successfully!');
        state = state.copyWith(state: ResetPasswordState.success);
      } else {
        debugPrint('RESET_PASSWORD: Password reset failed');
        state = state.copyWith(
          state: ResetPasswordState.error,
          errorMessage: 'Error al cambiar la contraseña. Intenta de nuevo.',
        );
      }
    } catch (e) {
      debugPrint('RESET_PASSWORD ERROR: $e');
      
      String errorMessage;
      if (e.toString().contains('Código inválido')) {
        errorMessage = 'Código inválido o expirado. Solicita un nuevo código de recuperación.';
      } else if (e.toString().contains('404') || e.toString().contains('Email not found')) {
        errorMessage = 'Email no encontrado. Verifica que el email sea correcto.';
      } else if (e.toString().contains('Connection') || e.toString().contains('timeout')) {
        errorMessage = 'Error de conexión. Verifica tu conexión a internet.';
      } else {
        errorMessage = 'Error al cambiar la contraseña. Intenta de nuevo.';
      }

      state = state.copyWith(
        state: ResetPasswordState.error,
        errorMessage: errorMessage,
      );
    }
  }

  Future<void> resetPasswordWithToken({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    debugPrint('RESET_PASSWORD: Completing password reset with token for email: $email');
    state = state.copyWith(state: ResetPasswordState.loading);

    try {
      // Use the token-based reset password endpoint
      debugPrint('RESET_PASSWORD: Using reset password with token endpoint...');
      final isReset = await _authApi.resetPasswordWithToken(email, resetToken, newPassword);
      
      if (isReset) {
        debugPrint('RESET_PASSWORD: Password reset with token successfully!');
        state = state.copyWith(state: ResetPasswordState.success);
      } else {
        debugPrint('RESET_PASSWORD: Password reset with token failed');
        state = state.copyWith(
          state: ResetPasswordState.error,
          errorMessage: 'Error al cambiar la contraseña. Intenta de nuevo.',
        );
      }
    } catch (e) {
      debugPrint('RESET_PASSWORD ERROR: $e');
      
      String errorMessage;
      if (e.toString().contains('Token inválido')) {
        errorMessage = 'Token inválido o expirado. Solicita un nuevo código de recuperación.';
      } else if (e.toString().contains('404') || e.toString().contains('Email not found')) {
        errorMessage = 'Email no encontrado. Verifica que el email sea correcto.';
      } else if (e.toString().contains('Connection') || e.toString().contains('timeout')) {
        errorMessage = 'Error de conexión. Verifica tu conexión a internet.';
      } else {
        errorMessage = 'Error al cambiar la contraseña. Intenta de nuevo.';
      }

      state = state.copyWith(
        state: ResetPasswordState.error,
        errorMessage: errorMessage,
      );
    }
  }

  void clearError() {
    if (state.state == ResetPasswordState.error) {
      state = state.copyWith(state: ResetPasswordState.initial, errorMessage: null);
    }
  }
}

final resetPasswordControllerProvider = StateNotifierProvider<ResetPasswordController, ResetPasswordStateData>((ref) {
  final authApi = ref.watch(authApiProvider);
  
  return ResetPasswordController(authApi);
});