import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../../api/auth_api.dart';
import '../../../../api/users_api.dart';
import '../../../../api/api_client.dart';
import '../../../../api/models/user_models.dart';
import '../../../../api/models/auth_models.dart';
import '../../../../providers/api_providers.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/firebase_auth_service.dart';

enum SignUpState {
  initial,
  loading,
  success,
  error,
}

class SignUpStateData {
  final SignUpState state;
  final String? errorMessage;
  final String? userEmail;

  const SignUpStateData({
    required this.state,
    this.errorMessage,
    this.userEmail,
  });

  SignUpStateData copyWith({
    SignUpState? state,
    String? errorMessage,
    String? userEmail,
  }) {
    return SignUpStateData(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

class SignUpController extends StateNotifier<SignUpStateData> {
  final AuthApi _authApi;
  final UsersApi _usersApi;
  final ApiClient _apiClient;
  final AuthNotifier _authNotifier;
  final FirebaseAuthService _firebaseAuthService;
  
  // Generate default avatar URL based on user's name
  String _getDefaultAvatarUrl(String name) {
    final encodedName = Uri.encodeComponent(name);
    return 'https://ui-avatars.com/api/?name=$encodedName&background=4ABDCA&color=fff&size=200';
  }

  SignUpController(this._authApi, this._usersApi, this._apiClient, this._authNotifier, this._firebaseAuthService)
      : super(const SignUpStateData(state: SignUpState.initial));

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      state = state.copyWith(
        state: SignUpState.error,
        errorMessage: 'Por favor completa todos los campos',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      state = state.copyWith(
        state: SignUpState.error,
        errorMessage: 'Por favor ingresa un email válido',
      );
      return;
    }

    final passwordValidation = _validatePassword(password);
    if (passwordValidation != null) {
      state = state.copyWith(
        state: SignUpState.error,
        errorMessage: passwordValidation,
      );
      return;
    }

    if (password != confirmPassword) {
      state = state.copyWith(
        state: SignUpState.error,
        errorMessage: 'Las contraseñas no coinciden',
      );
      return;
    }

    debugPrint('SIGNUP: Starting signup process for email: $email');
    state = state.copyWith(state: SignUpState.loading);

    try {
      // Step 1: Create user in Firebase Auth first
      debugPrint('SIGNUP: Creating user in Firebase Auth...');
      debugPrint('Email: $email');
      debugPrint('Name: $name');
      
      final userCredential = await _firebaseAuthService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('Failed to create Firebase user');
      }
      
      debugPrint('SIGNUP: Firebase user created successfully!');
      debugPrint('Firebase User ID: ${userCredential.user!.uid}');
      
      // Step 2: Get Firebase ID token
      debugPrint('SIGNUP: Getting Firebase ID token...');
      final idToken = await userCredential.user!.getIdToken();
      
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }
      
      debugPrint('SIGNUP: Firebase ID token obtained');
      debugPrint('Token starts with: ${idToken.substring(0, 4)}');
      
      // Step 3: Create user in backend API using Firebase token
      debugPrint('SIGNUP: Creating user in backend API...');
      debugPrint('Role: client');
      
      final userCreate = UserCreate(
        email: email,
        displayName: name,
        password: password,
        role: 'client',
      );
      
      final createdUser = await _usersApi.createUser(userCreate);
      debugPrint('SIGNUP: User created in backend successfully!');
      debugPrint('Created User ID: ${createdUser.id}');
      
      debugPrint('SIGNUP: User registration completed successfully!');
      debugPrint('SIGNUP: Email verification sent to ${createdUser.email}');
      state = state.copyWith(
        state: SignUpState.success,
        userEmail: createdUser.email,
      );
    } catch (e) {
      debugPrint('SIGNUP ERROR: $e');
      debugPrint('Error Type: ${e.runtimeType}');
      
      String errorMessage;
      
      if (e is RateLimitException) {
        debugPrint('SIGNUP: Rate limit exceeded for user creation');
        debugPrint('Blocked until: ${e.blockedUntil}');
        
        if (e.blockedUntil != null) {
          try {
            final blockedUntil = DateTime.parse(e.blockedUntil!);
            final now = DateTime.now();
            final difference = blockedUntil.difference(now);
            
            if (difference.inMinutes > 0) {
              errorMessage = 'Demasiados intentos de registro. Bloqueado por ${difference.inMinutes} minutos.\n'
                           'Intenta crear tu cuenta más tarde.';
            } else {
              errorMessage = 'Demasiados intentos de registro. Espera unos minutos antes de intentar de nuevo.';
            }
          } catch (_) {
            errorMessage = '${e.message}\nIntenta crear tu cuenta más tarde.';
          }
        } else {
          errorMessage = '${e.message}\nIntenta crear tu cuenta más tarde.';
        }
      } else {
        // Handle other types of errors
        String rawMessage = e.toString().replaceFirst('Exception: ', '');
        debugPrint('Processed Error Message: $rawMessage');
        
        // Handle specific error cases
        if (rawMessage.contains('email_already_exists') || rawMessage.contains('already exists') || rawMessage.contains('User already exists')) {
          debugPrint('SIGNUP: User already exists');
          errorMessage = 'Ya existe una cuenta con este email. Intenta iniciar sesión en su lugar.';
        } else if (rawMessage.contains('409') || rawMessage.contains('Conflict')) {
          debugPrint('SIGNUP: Email conflict (409)');
          errorMessage = 'Este email ya está registrado. Usa otro email o inicia sesión.';
        } else if (rawMessage.contains('429') || rawMessage.contains('Too Many Requests')) {
          debugPrint('SIGNUP: Rate limit (429) - fallback handling');
          errorMessage = 'Demasiados intentos de registro. Espera unos minutos antes de intentar crear tu cuenta de nuevo.';
        } else if (rawMessage.contains('Missing bearer token') || rawMessage.contains('Unauthorized')) {
          debugPrint('SIGNUP: Authorization required for user creation');
          errorMessage = 'Error del servidor: El registro de usuarios requiere configuración adicional. '
                       'Por favor contacta al administrador para crear tu cuenta.';
        } else if (rawMessage.contains('Invalid email or password')) {
          debugPrint('SIGNUP: Invalid credentials during login step');
          errorMessage = 'Las credenciales son incorrectas. Si acabas de crear la cuenta, intenta iniciar sesión.';
        } else if (rawMessage.contains('Connection') || rawMessage.contains('timeout')) {
          debugPrint('SIGNUP: Connection issues');
          errorMessage = 'Error de conexión: No se puede conectar al servidor. Verifica que el backend esté ejecutándose.';
        } else {
          debugPrint('SIGNUP: Unknown error');
          errorMessage = 'Error al crear la cuenta: $rawMessage';
        }
      }
      
      debugPrint('Final Error Message: $errorMessage');
      
      state = state.copyWith(
        state: SignUpState.error,
        errorMessage: errorMessage,
      );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'La contraseña debe contener al menos una letra mayúscula';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'La contraseña debe contener al menos una letra minúscula';
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'La contraseña debe contener al menos un número';
    }

    // Check for at least one symbol/special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'La contraseña debe contener al menos un símbolo (!@#\$%^&*(),.?":{}|<>)';
    }

    return null; // Password is valid
  }

  void clearError() {
    if (state.state == SignUpState.error) {
      state = state.copyWith(state: SignUpState.initial, errorMessage: null);
    }
  }
}

final signUpControllerProvider = StateNotifierProvider<SignUpController, SignUpStateData>((ref) {
  final authApi = ref.watch(authApiProvider);
  final usersApi = ref.watch(usersApiProvider);
  final apiClient = ref.watch(apiClientProvider);
  final authNotifier = ref.read(authProvider.notifier);
  final firebaseAuthService = FirebaseAuthService();
  
  return SignUpController(authApi, usersApi, apiClient, authNotifier, firebaseAuthService);
});