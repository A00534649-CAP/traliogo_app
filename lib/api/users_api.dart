import 'package:dio/dio.dart';
import 'api_client.dart';
import 'models/user_models.dart';
import 'models/auth_models.dart';

class UsersApi {
  final ApiClient _client;

  UsersApi(this._client);

  Future<List<UserOut>> listUsers({int limit = 20, int offset = 0}) async {
    try {
      final response = await _client.get<List<dynamic>>(
        '/api/v1/users',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data == null) {
        return [];
      }

      return response.data!
          .map((json) => UserOut.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch users: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<UserOut> createUser(UserCreate body) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/users/',
        data: body.toJson(),
        // Authentication required for user creation
      );

      if (response.data == null) {
        throw Exception('Create user response is null');
      }

      try {
        return UserOut.fromJson(response.data!);
      } catch (parseError) {
        throw Exception('Failed to parse user response: $parseError. Response: ${response.data}');
      }
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
              message: 'Demasiados intentos de registro. Espera antes de volver a intentar.',
              blockedUntil: null,
            );
          }
        }
        throw RateLimitException(
          message: 'Demasiados intentos de registro. Espera antes de volver a intentar.',
          blockedUntil: null,
        );
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid user data');
      } else if (e.response?.statusCode == 409) {
        throw Exception('User already exists');
      } else {
        throw Exception('Failed to create user: ${e.message}');
      }
    } catch (e) {
      if (e is RateLimitException) {
        rethrow;
      }
      throw Exception('Failed to create user: $e');
    }
  }

  Future<UserOut> getUser(String docId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/v1/users/$docId',
      );

      if (response.data == null) {
        throw Exception('User not found');
      }

      return UserOut.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to fetch user: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  Future<UserOut> updateUser(String docId, UserUpdate body) async {
    try {
      final response = await _client.put<Map<String, dynamic>>(
        '/api/v1/users/$docId',
        data: body.toJson(),
      );

      if (response.data == null) {
        throw Exception('Update user response is null');
      }

      return UserOut.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid user data');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to update user: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String docId) async {
    try {
      await _client.delete('/api/v1/users/$docId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Failed to delete user: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}