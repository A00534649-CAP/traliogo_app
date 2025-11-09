import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../api/auth_api.dart';
import '../../../../providers/api_providers.dart';

enum VerifyResetCodeState {
  initial,
  loading,
  success,
  error,
}

class VerifyResetCodeStateData {
  final VerifyResetCodeState state;
  final String? errorMessage;
  final String? email;
  final String? code;
  final String? resetToken;

  const VerifyResetCodeStateData({
    required this.state,
    this.errorMessage,
    this.email,
    this.code,
    this.resetToken,
  });

  VerifyResetCodeStateData copyWith({
    VerifyResetCodeState? state,
    String? errorMessage,
    String? email,
    String? code,
    String? resetToken,
  }) {
    return VerifyResetCodeStateData(
      state: state ?? this.state,
      errorMessage: errorMessage,
      email: email ?? this.email,
      code: code ?? this.code,
      resetToken: resetToken ?? this.resetToken,
    );
  }
}

class VerifyResetCodeController extends StateNotifier<VerifyResetCodeStateData> {
  final AuthApi _authApi;

  VerifyResetCodeController(this._authApi)
      : super(const VerifyResetCodeStateData(state: VerifyResetCodeState.initial));

  Future<void> verifyResetCode({
    required String email,
    required String code,
  }) async {
    debugPrint('VERIFY_RESET_CODE: Verifying reset code for email: $email');
    state = state.copyWith(state: VerifyResetCodeState.loading);

    try {
      final resetToken = await _authApi.verifyResetCode(email, code);
      
      if (resetToken != null) {
        debugPrint('VERIFY_RESET_CODE: Reset code verified successfully! Token received.');
        state = state.copyWith(
          state: VerifyResetCodeState.success,
          email: email,
          code: code,
          resetToken: resetToken,
        );
      } else {
        debugPrint('VERIFY_RESET_CODE: Reset code is incorrect');
        state = state.copyWith(
          state: VerifyResetCodeState.error,
          errorMessage: 'Código incorrecto. Verifica el código de 6 dígitos enviado a tu email.',
        );
      }
    } catch (e) {
      debugPrint('VERIFY_RESET_CODE ERROR: $e');
      
      String errorMessage;
      if (e.toString().contains('Código inválido')) {
        errorMessage = 'Código inválido o expirado. Solicita un nuevo código.';
      } else if (e.toString().contains('404') || e.toString().contains('Email not found')) {
        errorMessage = 'Email no encontrado. Verifica que el email sea correcto.';
      } else if (e.toString().contains('Connection') || e.toString().contains('timeout')) {
        errorMessage = 'Error de conexión. Verifica tu conexión a internet.';
      } else {
        errorMessage = 'Error al verificar el código. Intenta de nuevo.';
      }

      state = state.copyWith(
        state: VerifyResetCodeState.error,
        errorMessage: errorMessage,
      );
    }
  }

  void clearError() {
    if (state.state == VerifyResetCodeState.error) {
      state = state.copyWith(state: VerifyResetCodeState.initial, errorMessage: null);
    }
  }
}

final verifyResetCodeControllerProvider = StateNotifierProvider<VerifyResetCodeController, VerifyResetCodeStateData>((ref) {
  final authApi = ref.watch(authApiProvider);
  
  return VerifyResetCodeController(authApi);
});