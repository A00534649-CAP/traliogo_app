import 'package:dio/dio.dart';
import 'api_client.dart';
import 'models/common_models.dart';

class AdminApi {
  final ApiClient _client;

  AdminApi(this._client);

  Future<SystemMetricsResponse> getMetrics() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/v1/admin/metrics',
      );

      if (response.data == null) {
        throw Exception('System metrics response is null');
      }

      return SystemMetricsResponse.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Insufficient permissions');
      } else {
        throw Exception('Failed to fetch system metrics: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch system metrics: $e');
    }
  }
}