// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserOut _$UserOutFromJson(Map<String, dynamic> json) => UserOut(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  role: json['role'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserOutToJson(UserOut instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'displayName': instance.displayName,
  'avatarUrl': instance.avatarUrl,
  'role': instance.role,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

UserCreate _$UserCreateFromJson(Map<String, dynamic> json) => UserCreate(
  email: json['email'] as String,
  displayName: json['displayName'] as String,
  role: json['role'] as String? ?? 'client',
  password: json['password'] as String,
);

Map<String, dynamic> _$UserCreateToJson(UserCreate instance) =>
    <String, dynamic>{
      'email': instance.email,
      'displayName': instance.displayName,
      'role': instance.role,
      'password': instance.password,
    };

UserUpdate _$UserUpdateFromJson(Map<String, dynamic> json) => UserUpdate(
  email: json['email'] as String?,
  displayName: json['displayName'] as String?,
  role: json['role'] as String?,
);

Map<String, dynamic> _$UserUpdateToJson(UserUpdate instance) =>
    <String, dynamic>{
      'email': instance.email,
      'displayName': instance.displayName,
      'role': instance.role,
    };
