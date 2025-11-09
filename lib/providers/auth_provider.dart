import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/models/user_models.dart';

class AuthState {
  final String? accessToken;
  final UserOut? user;
  final bool isAuthenticated;
  final bool isVerified;

  const AuthState({
    this.accessToken,
    this.user,
    this.isAuthenticated = false,
    this.isVerified = false,
  });

  AuthState copyWith({
    String? accessToken,
    UserOut? user,
    bool? isAuthenticated,
    bool? isVerified,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void setAuthData({
    required String accessToken,
    required UserOut user,
    bool? isVerified,
  }) {
    state = state.copyWith(
      accessToken: accessToken,
      user: user,
      isAuthenticated: true,
      isVerified: isVerified ?? false, // Default to unverified to require verification
    );
  }

  void setVerified() {
    state = state.copyWith(isVerified: true);
  }

  void logout() {
    state = const AuthState();
  }

  bool get requiresVerification {
    return state.isAuthenticated && !state.isVerified;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});