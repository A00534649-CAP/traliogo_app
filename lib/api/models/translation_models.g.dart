// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TranslationOut _$TranslationOutFromJson(Map<String, dynamic> json) =>
    TranslationOut(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      sourceText: json['source_text'] as String,
      targetText: json['target_text'] as String,
      sourceLanguage: json['source_language'] as String,
      targetLanguage: json['target_language'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TranslationOutToJson(TranslationOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'source_text': instance.sourceText,
      'target_text': instance.targetText,
      'source_language': instance.sourceLanguage,
      'target_language': instance.targetLanguage,
      'type': instance.type,
      'created_at': instance.createdAt.toIso8601String(),
    };

TranslationCreate _$TranslationCreateFromJson(Map<String, dynamic> json) =>
    TranslationCreate(
      userId: json['user_id'] as String,
      sourceText: json['source_text'] as String,
      targetText: json['target_text'] as String,
      sourceLanguage: json['source_language'] as String,
      targetLanguage: json['target_language'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$TranslationCreateToJson(TranslationCreate instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'source_text': instance.sourceText,
      'target_text': instance.targetText,
      'source_language': instance.sourceLanguage,
      'target_language': instance.targetLanguage,
      'type': instance.type,
    };
