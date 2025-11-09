import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../api/auth_api.dart';
import '../../../../api/api_client.dart';
import '../../../../api/models/user_models.dart';
import '../../../../api/models/auth_models.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/firebase_auth_service.dart';

enum LoginState {
  initial,
  loading,
  success,
  error,
  needsVerification,
}

class LoginStateData {
  final LoginState state;
  final String? errorMessage;
  final String? email;

  const LoginStateData({
    required this.state,
    this.errorMessage,
    this.email,
  });

  LoginStateData copyWith({
    LoginState? state,
    String? errorMessage,
    String? email,
  }) {
    return LoginStateData(
      state: state ?? this.state,
      errorMessage: errorMessage,
      email: email ?? this.email,
    );
  }
}

class LoginController extends StateNotifier<LoginStateData> {
  final AuthApi _authApi;
  final ApiClient _apiClient;
  final AuthNotifier _authNotifier;
  final FirebaseAuthService _firebaseAuthService;
  
  // Generate default avatar URL based on user's name
  String _getDefaultAvatarUrl(String name) {
    final encodedName = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encodedName&background=4ABDCA&color=fff&size=200';
  }

  LoginController(this._authApi, this._apiClient, this._authNotifier, this._firebaseAuthService)
      : super(const LoginStateData(state: LoginState.initial));

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      state = state.copyWith(
        state: LoginState.error,
        errorMessage: 'Por favor ingresa email y contraseña',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      state = state.copyWith(
        state: LoginState.error,
        errorMessage: 'Por favor ingresa un email válido',
      );
      return;
    }

    debugPrint('LOGIN: Starting login process for email: $email');
    state = state.copyWith(state: LoginState.loading);

    try {
      // Call AuthApi.login(email) - new backend only needs email
      debugPrint('LOGIN: Calling AuthApi.login...');
      final loginResponse = await _authApi.login(email, password);
      
      debugPrint('LOGIN: Login response received!');
      debugPrint('User ID: ${loginResponse.userId}');
      debugPrint('Email Verified: ${loginResponse.emailVerified}');
      debugPrint('Access Token: ${loginResponse.accessToken.substring(0, 20)}...');
      
      // Store access_token and configure ApiClient as per U1 requirements
      _apiClient.setAccessToken(loginResponse.accessToken);
      debugPrint('LOGIN: ApiClient configured with access token');
      
      // Create user object with available data (U1 expects user object)
      final userName = email.split('@')[0]; // Fallback display name
      final user = UserOut(
        id: loginResponse.userId,
        email: email,
        displayName: userName,
        avatarUrl: _getDefaultAvatarUrl(userName), // Generate default avatar
        role: 'client',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(), // This is fine since we're creating it manually
      );
      debugPrint('LOGIN: Created user object for: ${user.displayName ?? user.email}');
      
      // Store access_token and user in session/auth provider
      _authNotifier.setAuthData(
        accessToken: loginResponse.accessToken,
        user: user,
        isVerified: true, // They're verified if they got this far
      );
      debugPrint('LOGIN: Auth state updated successfully');

      state = state.copyWith(state: LoginState.success);
      debugPrint('LOGIN: Process completed successfully!');
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      debugPrint('Error Type: ${e.runtimeType}');
      
      if (e is EmailNotVerifiedException) {
        debugPrint('LOGIN: Email verification required, redirecting to login verification page');
        debugPrint('LOGIN: Backend already sent verification code automatically');
        
        state = state.copyWith(
          state: LoginState.needsVerification,
          email: e.email,
        );
        return;
      }
      
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('Final Error Message: $errorMessage');
      
      state = state.copyWith(
        state: LoginState.error,
        errorMessage: errorMessage,
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void clearError() {
    if (state.state == LoginState.error) {
      state = state.copyWith(state: LoginState.initial, errorMessage: null);
    }
  }
}

final loginControllerProvider = StateNotifierProvider<LoginController, LoginStateData>((ref) {
  final authApi = ref.watch(authApiProvider);
  final apiClient = ref.watch(apiClientProvider);
  final authNotifier = ref.read(authProvider.notifier);
  final firebaseAuthService = FirebaseAuthService();
  
  return LoginController(authApi, apiClient, authNotifier, firebaseAuthService);
});