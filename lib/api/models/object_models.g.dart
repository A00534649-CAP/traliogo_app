// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'object_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObjectOut _$ObjectOutFromJson(Map<String, dynamic> json) => ObjectOut(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  objectName: json['object_name'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  imageUrl: json['image_url'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ObjectOutToJson(ObjectOut instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'object_name': instance.objectName,
  'confidence': instance.confidence,
  'image_url': instance.imageUrl,
  'created_at': instance.createdAt.toIso8601String(),
};

ObjectCreate _$ObjectCreateFromJson(Map<String, dynamic> json) => ObjectCreate(
  userId: json['user_id'] as String,
  objectName: json['object_name'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$ObjectCreateToJson(ObjectCreate instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'object_name': instance.objectName,
      'confidence': instance.confidence,
      'image_url': instance.imageUrl,
    };
