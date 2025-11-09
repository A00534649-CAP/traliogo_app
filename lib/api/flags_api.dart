import 'package:dio/dio.dart';
import 'api_client.dart';
import 'models/common_models.dart';

class FlagsApi {
  final ApiClient _client;

  FlagsApi(this._client);

  Future<FeatureFlagsResponse> getFlags() async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/v1/flags',
      );

      if (response.data == null) {
        throw Exception('Feature flags response is null');
      }

      return FeatureFlagsResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw Exception('Failed to fetch feature flags: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch feature flags: $e');
    }
  }

  Future<FeatureFlagsResponse> updateFlags(FeatureFlagsUpdateRequest body) async {
    try {
      final response = await _client.put<Map<String, dynamic>>(
        '/api/v1/flags',
        data: body.toJson(),
      );

      if (response.data == null) {
        throw Exception('Update feature flags response is null');
      }

      return FeatureFlagsResponse.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid feature flags data');
      } else {
        throw Exception('Failed to update feature flags: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to update feature flags: $e');
    }
  }
}