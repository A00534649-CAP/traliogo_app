import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/firebase_auth_service.dart';

class ApiClient {
  static const String _baseUrl = 'http://10.0.2.2:8080';
  
  late final Dio _dio;
  String? _accessToken;
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Add logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Skip auth for public endpoints
          final skipAuth = options.extra['skipAuth'] == true;
          
          debugPrint('API REQUEST [${options.method}] ${options.uri}');
          debugPrint('Headers: ${options.headers}');
          debugPrint('Data: ${options.data}');
          debugPrint('Skip Auth: $skipAuth');
          
          if (!skipAuth) {
            // Try to get Firebase ID token from authenticated user
            final idToken = await _firebaseAuthService.getIdToken();
            if (idToken != null) {
              options.headers['Authorization'] = 'Bearer $idToken';
              debugPrint('Added Firebase ID token to Authorization header');
              debugPrint('Token: ${idToken.substring(0, 20)}...');
              debugPrint('Token starts with: ${idToken.substring(0, 4)}');
            } else if (_accessToken != null) {
              // Fallback to custom access token if no Firebase token
              options.headers['Authorization'] = 'Bearer $_accessToken';
              debugPrint('Added fallback Authorization header');
            } else {
              debugPrint('No authentication token available');
            }
          } else {
            // For public endpoints, skip authentication entirely
            debugPrint('API CLIENT: Skipping authentication for public endpoint (skipAuth: true)');
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('API RESPONSE [${response.statusCode}] ${response.requestOptions.uri}');
          debugPrint('Response Data: ${response.data}');
          handler.next(response);
        },
        onError: (DioException error, handler) {
          debugPrint('API ERROR [${error.response?.statusCode ?? 'NO_STATUS'}] ${error.requestOptions.uri}');
          debugPrint('Error Type: ${error.type}');
          debugPrint('Error Message: ${error.message}');
          debugPrint('Response Data: ${error.response?.data}');
          debugPrint('Response Headers: ${error.response?.headers}');
          
          // Log specific error details
          switch (error.type) {
            case DioExceptionType.connectionTimeout:
              debugPrint('Connection timeout - Backend may not be running on $_baseUrl');
              break;
            case DioExceptionType.receiveTimeout:
              debugPrint('Receive timeout - Server is slow to respond');
              break;
            case DioExceptionType.connectionError:
              debugPrint('Connection error - Check if backend is running and accessible');
              break;
            case DioExceptionType.badResponse:
              debugPrint('Bad response - Server returned error ${error.response?.statusCode}');
              break;
            case DioExceptionType.unknown:
              debugPrint('Unknown error - ${error.message}');
              break;
            default:
              debugPrint('Other error type: ${error.type}');
          }
          
          if (error.response?.statusCode == 401) {
            debugPrint('401 Unauthorized - Clearing access token');
            _accessToken = null;
          }
          
          handler.next(error);
        },
      ),
    );
  }

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  String? get accessToken => _accessToken;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}