import 'package:dio/dio.dart';
import 'api_client.dart';
import 'models/auth_models.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<LoginResponse> login(String email, String password) async {
    try {
      // Use login-with-password endpoint that validates credentials first
      final loginData = {
        'email': email,
        'password': password,
      };
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/login-with-password',
        data: loginData,
        options: Options(extra: {'skipAuth': true}),
      );

      if (response.data == null) {
        throw Exception('Login response is null');
      }

      final loginResponse = LoginResponse.fromJson(response.data!);
      
      // Check if login was successful
      if (!loginResponse.success) {
        // If token is null, it means verification is required regardless of email_verified status
        if (loginResponse.token == null) {
          throw EmailNotVerifiedException(
            message: loginResponse.message ?? 'Se requiere verificación por código',
            email: loginResponse.email,
          );
        } else {
          throw Exception(loginResponse.message ?? 'Login failed');
        }
      }

      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Contraseña incorrecta');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Datos de solicitud inválidos');
      } else {
        throw Exception('Error de login: ${e.message}');
      }
    } catch (e) {
      if (e is EmailNotVerifiedException) {
        rethrow;
      }
      throw Exception('Login failed: $e');
    }
  }

  Future<VerifyTokenResponse> verifyToken(String idToken) async {
    try {
      final verifyData = VerifyTokenRequest(idToken: idToken);
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/verify-token',
        data: verifyData.toJson(),
      );

      if (response.data == null) {
        throw Exception('Verify token response is null');
      }

      return VerifyTokenResponse.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid token format');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Token verification failed');
      } else {
        throw Exception('Token verification failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Token verification failed: $e');
    }
  }

  Future<ResendVerificationResponse> resendVerification(String email) async {
    try {
      final resendData = ResendVerificationRequest(email: email);
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/resend-verification',
        data: resendData.toJson(),
        options: Options(extra: {'skipAuth': true}),
      );

      if (response.data == null) {
        throw Exception('Empty response from server');
      }

      return ResendVerificationResponse.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        // Rate limit exceeded - extract structured error
        if (e.response?.data != null) {
          try {
            final errorResponse = RateLimitErrorResponse.fromJson(e.response!.data);
            throw RateLimitException(
              message: errorResponse.detail.message,
              blockedUntil: errorResponse.detail.blockedUntil,
            );
          } catch (_) {
            // If JSON parsing fails, fall back to generic message
            throw RateLimitException(
              message: 'Demasiados intentos. Espera antes de volver a intentar.',
              blockedUntil: null,
            );
          }
        }
        throw RateLimitException(
          message: 'Demasiados intentos. Espera antes de volver a intentar.',
          blockedUntil: null,
        );
      } else if (e.response?.statusCode == 404) {
        throw Exception('Email not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Email already verified');
      } else {
        throw Exception('Failed to resend verification: ${e.message}');
      }
    } catch (e) {
      if (e is RateLimitException) {
        rethrow;
      }
      throw Exception('Failed to resend verification: $e');
    }
  }

  Future<bool> checkEmailVerification(String email) async {
    try {
      final verifyData = VerifyEmailRequest(email: email);
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/verify-email',
        data: verifyData.toJson(),
      );

      if (response.data == null) {
        return false;
      }

      return response.data!['verified'] ?? false; // Changed from 'email_verified' to 'verified' based on user's flow
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Email not found');
      } else {
        throw Exception('Failed to check verification status: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to check verification status: $e');
    }
  }

  Future<bool> verifyCode(String email, String code) async {
    try {
      final verifyData = {'email': email, 'code': code};
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/verify-code',
        data: verifyData,
        options: Options(extra: {'skipAuth': true}),
      );

      if (response.data == null) {
        return false;
      }

      return response.data!['success'] ?? false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Código inválido o expirado');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Email not found');
      } else {
        throw Exception('Error al verificar el código: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al verificar el código: $e');
    }
  }

  Future<void> sendLoginVerificationCode(String email) async {
    try {
      final sendData = {'email': email};
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/send-code',
        data: sendData,
        options: Options(extra: {'skipAuth': true}),
      );

      // Success if no exception is thrown
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        // Rate limit exceeded - extract structured error
        if (e.response?.data != null) {
          try {
            final errorResponse = RateLimitErrorResponse.fromJson(e.response!.data);
            throw RateLimitException(
              message: errorResponse.detail.message,
              blockedUntil: errorResponse.detail.blockedUntil,
            );
          } catch (_) {
            // If JSON parsing fails, fall back to generic message
            throw RateLimitException(
              message: 'Demasiados intentos. Espera antes de volver a intentar.',
              blockedUntil: null,
            );
          }
        }
        throw RateLimitException(
          message: 'Demasiados intentos. Espera antes de volver a intentar.',
          blockedUntil: null,
        );
      } else if (e.response?.statusCode == 404) {
        throw Exception('Email not found');
      } else {
        throw Exception('Failed to send verification email: ${e.message}');
      }
    } catch (e) {
      if (e is RateLimitException) {
        rethrow;
      }
      throw Exception('Failed to send verification email: $e');
    }
  }

  // Complete login after verifying code
  Future<LoginResponse> completeLogin(String email, String code) async {
    try {
      final loginData = {
        'email': email,
        'code': code,
      };
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/complete-login',
        data: loginData,
        options: Options(extra: {'skipAuth': true}),
      );

      if (response.data == null) {
        throw Exception('Complete login response is null');
      }

      final loginResponse = LoginResponse.fromJson(response.data!);
      
      // Check if login was successful
      if (!loginResponse.success) {
        throw Exception(loginResponse.message ?? 'Complete login failed');
      }

      return loginResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Código inválido o expirado');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Email not found');
      } else {
        throw Exception('Complete login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Complete login failed: $e');
    }
  }

  // Forgot password flow methods
  Future<void> forgotPassword(String email) async {
    try {
      final sendData = {'email': email};
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/forgot-password',
        data: sendData,
        options: Options(extra: {'skipAuth': true}),
      );

      // Success if no exception is thrown
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        // Rate limit exceeded - extract structured error
        if (e.response?.data != null) {
          try {
            final errorResponse = RateLimitErrorResponse.fromJson(e.response!.data);
            throw RateLimitException(
              message: errorResponse.detail.message,
              blockedUntil: errorResponse.detail.blockedUntil,
            );
          } catch (_) {
            // If JSON parsing fails, fall back to generic message
            throw RateLimitException(
              message: 'Demasiados intentos. Espera antes de volver a intentar.',
              blockedUntil: null,
            );
          }
        }
        throw RateLimitException(
          message: 'Demasiados intentos. Espera antes de volver a intentar.',
          blockedUntil: null,
        );
      } else if (e.response?.statusCode == 404) {
        throw Exception('Email not found');
      } else {
        throw Exception('Failed to send reset code: ${e.message}');
      }
    } catch (e) {
      if (e is RateLimitException) {
        rethrow;
      }
      throw Exception('Failed to send reset code: $e');
    }
  }

  Future<String?> verifyResetCode(String email, String code) async {
    try {
      final verifyData = {'email': email, 'code': code};
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/verify-reset-code',
        data: verifyData,
        options: Options(extra: {'skipAuth': true}),
      );

      if (response.data == null) {
        return null;
      }

      final data = response.data!;
      if (data['success'] == true) {
        return data['reset_token'] as String?;
      }
      
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Código inválido o expirado');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Email not found');
      } else {
        throw Exception('Error al verificar el código: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al verificar el código: $e');
    }
  }

  Future<bool> resetPassword(String email, String code, String newPassword) async {
    try {
      final resetData = {
        'email': email,
        'code': code,
        'new_password': newPassword,
      };
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/reset-password',
        data: resetData,
        options: Options(extra: {'skipAuth': true}),
      );

      if (response.data == null) {
        return false;
      }

      return response.data!['success'] ?? false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Código inválido o expirado');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Email not found');
      } else {
        throw Exception('Error al cambiar la contraseña: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al cambiar la contraseña: $e');
    }
  }

  Future<bool> resetPasswordWithToken(String email, String resetToken, String newPassword) async {
    try {
      final resetData = {
        'email': email,
        'reset_token': resetToken,
        'new_password': newPassword,
      };
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/reset-password',
        data: resetData,
        options: Options(extra: {'skipAuth': true}),
      );

      if (response.data == null) {
        return false;
      }

      return response.data!['success'] ?? false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Token inválido o expirado');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Email not found');
      } else {
        throw Exception('Error al cambiar la contraseña: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al cambiar la contraseña: $e');
    }
  }

  // Combined reset password flow - verify code and reset password in one call
  Future<bool> completePasswordReset(String email, String code, String newPassword) async {
    try {
      final resetData = {
        'email': email,
        'code': code,
        'new_password': newPassword,
      };
      
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/auth/complete-password-reset',
        data: resetData,
        options: Options(extra: {'skipAuth': true}),
      );

      if (response.data == null) {
        return false;
      }

      return response.data!['success'] ?? false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Código inválido o expirado');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Email not found');
      } else {
        throw Exception('Error al cambiar la contraseña: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error al cambiar la contraseña: $e');
    }
  }
}