import 'package:dio/dio.dart';
import 'api_client.dart';
import 'models/common_models.dart';

class HealthApi {
  final ApiClient _client;

  HealthApi(this._client);

  Future<HealthResponse> checkHealth() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/healthz',
      );

      if (response.data == null) {
        return const HealthResponse(status: 'unknown');
      }

      return HealthResponse.fromJson(response.data!);
    } on DioException catch (e) {
      return HealthResponse(
        status: 'error',
        message: 'Health check failed: ${e.message}',
      );
    } catch (e) {
      return HealthResponse(
        status: 'error',
        message: 'Health check failed: $e',
      );
    }
  }
}