import 'package:dio/dio.dart';
import 'api_client.dart';
import 'models/translation_models.dart';

class TranslationsApi {
  final ApiClient _client;

  TranslationsApi(this._client);

  Future<List<TranslationOut>> listTranslations({int limit = 20, int offset = 0}) async {
    try {
      final response = await _client.get<List<dynamic>>(
        '/api/v1/translations',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.data == null) {
        return [];
      }

      return response.data!
          .map((json) => TranslationOut.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch translations: ${e.message}');
    } catch (e) {
      throw Exception('Failed to fetch translations: $e');
    }
  }

  Future<TranslationOut> createTranslation(TranslationCreate body) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/api/v1/translations',
        data: body.toJson(),
      );

      if (response.data == null) {
        throw Exception('Create translation response is null');
      }

      return TranslationOut.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid translation data');
      } else {
        throw Exception('Failed to create translation: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to create translation: $e');
    }
  }

  Future<TranslationOut> getTranslation(String docId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>(
        '/api/v1/translations/$docId',
      );

      if (response.data == null) {
        throw Exception('Translation not found');
      }

      return TranslationOut.fromJson(response.data!);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Translation not found');
      } else {
        throw Exception('Failed to fetch translation: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to fetch translation: $e');
    }
  }

  Future<void> deleteTranslation(String docId) async {
    try {
      await _client.delete('/api/v1/translations/$docId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Translation not found');
      } else {
        throw Exception('Failed to delete translation: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to delete translation: $e');
    }
  }
}