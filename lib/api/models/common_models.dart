import 'package:json_annotation/json_annotation.dart';

part 'common_models.g.dart';

@JsonSerializable()
class FeatureFlagsResponse {
  final Map<String, bool> flags;

  const FeatureFlagsResponse({
    required this.flags,
  });

  factory FeatureFlagsResponse.fromJson(Map<String, dynamic> json) => _$FeatureFlagsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FeatureFlagsResponseToJson(this);
}

@JsonSerializable()
class FeatureFlagsUpdateRequest {
  final Map<String, bool> flags;

  const FeatureFlagsUpdateRequest({
    required this.flags,
  });

  factory FeatureFlagsUpdateRequest.fromJson(Map<String, dynamic> json) => _$FeatureFlagsUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FeatureFlagsUpdateRequestToJson(this);
}

@JsonSerializable()
class SystemMetricsResponse {
  @JsonKey(name: 'total_users')
  final int totalUsers;
  @JsonKey(name: 'total_translations')
  final int totalTranslations;
  @JsonKey(name: 'total_objects')
  final int totalObjects;
  @JsonKey(name: 'system_uptime')
  final String systemUptime;

  const SystemMetricsResponse({
    required this.totalUsers,
    required this.totalTranslations,
    required this.totalObjects,
    required this.systemUptime,
  });

  factory SystemMetricsResponse.fromJson(Map<String, dynamic> json) => _$SystemMetricsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SystemMetricsResponseToJson(this);
}

@JsonSerializable()
class HealthResponse {
  final String status;
  final String? message;

  const HealthResponse({
    required this.status,
    this.message,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) => _$HealthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$HealthResponseToJson(this);
}

@JsonSerializable()
class ErrorResponse {
  final String message;
  final String? detail;
  final int? code;

  const ErrorResponse({
    required this.message,
    this.detail,
    this.code,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) => _$ErrorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}