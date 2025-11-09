import 'package:dio/dio.dart';
import 'api_client.dart';
import 'models/object_models.dart';

class ObjectsApi {
  final ApiClient _client;

  ObjectsApi(this._client);

  Future<List<ObjectOut>> listObjects({int limit = 20, int offset = 0}) async {
    try {
      final response = await _client.get<List<dynamic>>(
        '/api/v1/objects',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data == null) {
        return [];
      }

      return response.data!
          .map((json) => ObjectOut.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch objects: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch objects: $e');
    }
  }

  Future<ObjectOut> createObject(ObjectCreate body) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/objects',
        data: body.toJson(),
      );

      if (response.data == null) {
        throw Exception('Create object response is null');
      }

      return ObjectOut.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid object data');
      } else {
        throw Exception('Failed to create object: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to create object: $e');
    }
  }

  Future<ObjectOut> getObject(String docId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/v1/objects/$docId',
      );

      if (response.data == null) {
        throw Exception('Object not found');
      }

      return ObjectOut.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Object not found');
      } else {
        throw Exception('Failed to fetch object: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch object: $e');
    }
  }

  Future<void> deleteObject(String docId) async {
    try {
      await _client.delete('/api/v1/objects/$docId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Object not found');
      } else {
        throw Exception('Failed to delete object: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to delete object: $e');
    }
  }
}