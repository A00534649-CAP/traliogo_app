import 'package:json_annotation/json_annotation.dart';
import 'user_models.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  @JsonKey(name: 'user_id')
  final String userId;
  final String? email;

  const LoginRequest({
    required this.userId,
    this.email,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class LoginResponse {
  final bool success;
  final String? token;
  @JsonKey(name: 'user_id')
  final String userId;
  final String email;
  @JsonKey(name: 'email_verified')
  final bool emailVerified;
  final String? message;

  const LoginResponse({
    required this.success,
    this.token,
    required this.userId,
    required this.email,
    required this.emailVerified,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
  
  // Helper getter to match our expected format
  String get accessToken => token ?? '';
}

@JsonSerializable()
class VerifyTokenRequest {
  @JsonKey(name: 'id_token')
  final String idToken;

  const VerifyTokenRequest({
    required this.idToken,
  });

  factory VerifyTokenRequest.fromJson(Map<String, dynamic> json) => _$VerifyTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyTokenRequestToJson(this);
}

@JsonSerializable()
class VerifyTokenResponse {
  @JsonKey(name: 'userId')
  final String uid;
  final String? email;
  @JsonKey(name: 'valid')
  final bool isValid;
  final bool? expired;

  const VerifyTokenResponse({
    required this.uid,
    this.email,
    required this.isValid,
    this.expired,
  });

  factory VerifyTokenResponse.fromJson(Map<String, dynamic> json) => _$VerifyTokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyTokenResponseToJson(this);
}

@JsonSerializable()
class ResendVerificationRequest {
  final String email;

  const ResendVerificationRequest({
    required this.email,
  });

  factory ResendVerificationRequest.fromJson(Map<String, dynamic> json) => _$ResendVerificationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResendVerificationRequestToJson(this);
}

@JsonSerializable()
class VerifyEmailRequest {
  final String email;

  const VerifyEmailRequest({
    required this.email,
  });

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) => _$VerifyEmailRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}

@JsonSerializable()
class ResendVerificationResponse {
  final String message;
  final bool sent;
  @JsonKey(name: 'attempts_remaining')
  final int? attemptsRemaining;
  @JsonKey(name: 'blocked_until')
  final String? blockedUntil;

  const ResendVerificationResponse({
    required this.message,
    required this.sent,
    this.attemptsRemaining,
    this.blockedUntil,
  });

  factory ResendVerificationResponse.fromJson(Map<String, dynamic> json) => _$ResendVerificationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ResendVerificationResponseToJson(this);
}

@JsonSerializable()
class RateLimitErrorDetail {
  final String error;
  final String message;
  @JsonKey(name: 'blocked_until')
  final String? blockedUntil;

  const RateLimitErrorDetail({
    required this.error,
    required this.message,
    this.blockedUntil,
  });

  factory RateLimitErrorDetail.fromJson(Map<String, dynamic> json) => _$RateLimitErrorDetailFromJson(json);
  Map<String, dynamic> toJson() => _$RateLimitErrorDetailToJson(this);
}

@JsonSerializable()
class RateLimitErrorResponse {
  final RateLimitErrorDetail detail;

  const RateLimitErrorResponse({
    required this.detail,
  });

  factory RateLimitErrorResponse.fromJson(Map<String, dynamic> json) => _$RateLimitErrorResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RateLimitErrorResponseToJson(this);
}

class RateLimitException implements Exception {
  final String message;
  final String? blockedUntil;

  const RateLimitException({
    required this.message,
    this.blockedUntil,
  });

  @override
  String toString() => message;
}

class EmailNotVerifiedException implements Exception {
  final String message;
  final String email;

  const EmailNotVerifiedException({
    required this.message,
    required this.email,
  });

  @override
  String toString() => message;
}