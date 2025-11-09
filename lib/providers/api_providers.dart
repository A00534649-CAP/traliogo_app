import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../api/users_api.dart';
import '../api/translations_api.dart';
import '../api/objects_api.dart';
import '../api/flags_api.dart';
import '../api/admin_api.dart';
import '../api/health_api.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthApi(client);
});

final usersApiProvider = Provider<UsersApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return UsersApi(client);
});

final translationsApiProvider = Provider<TranslationsApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return TranslationsApi(client);
});

final objectsApiProvider = Provider<ObjectsApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return ObjectsApi(client);
});

final flagsApiProvider = Provider<FlagsApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return FlagsApi(client);
});

final adminApiProvider = Provider<AdminApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AdminApi(client);
});

final healthApiProvider = Provider<HealthApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return HealthApi(client);
});