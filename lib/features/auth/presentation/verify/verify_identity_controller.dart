import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../api/auth_api.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/auth_provider.dart';

enum VerifyState {
  initial,
  loading,
  success,
  error,
}

class VerifyStateData {
  final VerifyState state;
  final String? errorMessage;

  const VerifyStateData({
    required this.state,
    this.errorMessage,
  });

  VerifyStateData copyWith({
    VerifyState? state,
    String? errorMessage,
  }) {
    return VerifyStateData(
      state: state ?? this.state,
      errorMessage: errorMessage,
    );
  }
}

class VerifyIdentityController extends StateNotifier<VerifyStateData> {
  final AuthApi _authApi;
  final AuthNotifier _authNotifier;

  VerifyIdentityController(this._authApi, this._authNotifier)
      : super(const VerifyStateData(state: VerifyState.initial));

  Future<void> verifyToken(String code) async {
    if (code.isEmpty) {
      state = state.copyWith(
        state: VerifyState.error,
        errorMessage: 'Please enter the verification code',
      );
      return;
    }

    state = state.copyWith(state: VerifyState.loading);

    try {
      final response = await _authApi.verifyToken(code);
      
      if (response.isValid) {
        _authNotifier.setVerified();
        state = state.copyWith(state: VerifyState.success);
      } else {
        state = state.copyWith(
          state: VerifyState.error,
          errorMessage: 'Invalid verification code',
        );
      }
    } catch (e) {
      state = state.copyWith(
        state: VerifyState.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void clearError() {
    if (state.state == VerifyState.error) {
      state = state.copyWith(state: VerifyState.initial, errorMessage: null);
    }
  }
}

final verifyIdentityControllerProvider = StateNotifierProvider<VerifyIdentityController, VerifyStateData>((ref) {
  final authApi = ref.watch(authApiProvider);
  final authNotifier = ref.read(authProvider.notifier);
  
  return VerifyIdentityController(authApi, authNotifier);
});