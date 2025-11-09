import 'package:json_annotation/json_annotation.dart';

part 'translation_models.g.dart';

@JsonSerializable()
class TranslationOut {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'source_text')
  final String sourceText;
  @JsonKey(name: 'target_text')
  final String targetText;
  @JsonKey(name: 'source_language')
  final String sourceLanguage;
  @JsonKey(name: 'target_language')
  final String targetLanguage;
  final String type;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const TranslationOut({
    required this.id,
    required this.userId,
    required this.sourceText,
    required this.targetText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.type,
    required this.createdAt,
  });

  factory TranslationOut.fromJson(Map<String, dynamic> json) => _$TranslationOutFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationOutToJson(this);
}

@JsonSerializable()
class TranslationCreate {
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'source_text')
  final String sourceText;
  @JsonKey(name: 'target_text')
  final String targetText;
  @JsonKey(name: 'source_language')
  final String sourceLanguage;
  @JsonKey(name: 'target_language')
  final String targetLanguage;
  final String type;

  const TranslationCreate({
    required this.userId,
    required this.sourceText,
    required this.targetText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.type,
  });

  factory TranslationCreate.fromJson(Map<String, dynamic> json) => _$TranslationCreateFromJson(json);
  Map<String, dynamic> toJson() => _$TranslationCreateToJson(this);
}