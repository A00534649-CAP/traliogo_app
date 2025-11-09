import 'package:json_annotation/json_annotation.dart';

part 'object_models.g.dart';

@JsonSerializable()
class ObjectOut {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'object_name')
  final String objectName;
  final double confidence;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const ObjectOut({
    required this.id,
    required this.userId,
    required this.objectName,
    required this.confidence,
    this.imageUrl,
    required this.createdAt,
  });

  factory ObjectOut.fromJson(Map<String, dynamic> json) => _$ObjectOutFromJson(json);
  Map<String, dynamic> toJson() => _$ObjectOutToJson(this);
}

@JsonSerializable()
class ObjectCreate {
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'object_name')
  final String objectName;
  final double confidence;
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  const ObjectCreate({
    required this.userId,
    required this.objectName,
    required this.confidence,
    this.imageUrl,
  });

  factory ObjectCreate.fromJson(Map<String, dynamic> json) => _$ObjectCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ObjectCreateToJson(this);
}