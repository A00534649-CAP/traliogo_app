import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

@JsonSerializable()
class UserOut {
  final String id;
  final String email;
  @JsonKey(name: 'displayName')
  final String? displayName;
  @JsonKey(name: 'avatarUrl')
  final String? avatarUrl;
  final String role;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  const UserOut({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserOut.fromJson(Map<String, dynamic> json) => _$UserOutFromJson(json);
  Map<String, dynamic> toJson() => _$UserOutToJson(this);
}

@JsonSerializable()
class UserCreate {
  final String email;
  @JsonKey(name: 'displayName')
  final String displayName;
  final String role;
  final String password;

  const UserCreate({
    required this.email,
    required this.displayName,
    this.role = 'client',
    required this.password,
  });

  factory UserCreate.fromJson(Map<String, dynamic> json) => _$UserCreateFromJson(json);
  Map<String, dynamic> toJson() => _$UserCreateToJson(this);
}

@JsonSerializable()
class UserUpdate {
  final String? email;
  @JsonKey(name: 'displayName')
  final String? displayName;
  final String? role;

  const UserUpdate({
    this.email,
    this.displayName,
    this.role,
  });

  factory UserUpdate.fromJson(Map<String, dynamic> json) => _$UserUpdateFromJson(json);
  Map<String, dynamic> toJson() => _$UserUpdateToJson(this);
}