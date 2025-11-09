// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'common_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeatureFlagsResponse _$FeatureFlagsResponseFromJson(
  Map<String, dynamic> json,
) => FeatureFlagsResponse(flags: Map<String, bool>.from(json['flags'] as Map));

Map<String, dynamic> _$FeatureFlagsResponseToJson(
  FeatureFlagsResponse instance,
) => <String, dynamic>{'flags': instance.flags};

FeatureFlagsUpdateRequest _$FeatureFlagsUpdateRequestFromJson(
  Map<String, dynamic> json,
) => FeatureFlagsUpdateRequest(
  flags: Map<String, bool>.from(json['flags'] as Map),
);

Map<String, dynamic> _$FeatureFlagsUpdateRequestToJson(
  FeatureFlagsUpdateRequest instance,
) => <String, dynamic>{'flags': instance.flags};

SystemMetricsResponse _$SystemMetricsResponseFromJson(
  Map<String, dynamic> json,
) => SystemMetricsResponse(
  totalUsers: (json['total_users'] as num).toInt(),
  totalTranslations: (json['total_translations'] as num).toInt(),
  totalObjects: (json['total_objects'] as num).toInt(),
  systemUptime: json['system_uptime'] as String,
);

Map<String, dynamic> _$SystemMetricsResponseToJson(
  SystemMetricsResponse instance,
) => <String, dynamic>{
  'total_users': instance.totalUsers,
  'total_translations': instance.totalTranslations,
  'total_objects': instance.totalObjects,
  'system_uptime': instance.systemUptime,
};

HealthResponse _$HealthResponseFromJson(Map<String, dynamic> json) =>
    HealthResponse(
      status: json['status'] as String,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$HealthResponseToJson(HealthResponse instance) =>
    <String, dynamic>{'status': instance.status, 'message': instance.message};

ErrorResponse _$ErrorResponseFromJson(Map<String, dynamic> json) =>
    ErrorResponse(
      message: json['message'] as String,
      detail: json['detail'] as String?,
      code: (json['code'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ErrorResponseToJson(ErrorResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'detail': instance.detail,
      'code': instance.code,
    };
