// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  userId: json['user_id'] as String,
  email: json['email'] as String?,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'user_id': instance.userId, 'email': instance.email};

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      success: json['success'] as bool,
      token: json['token'] as String?,
      userId: json['user_id'] as String,
      email: json['email'] as String,
      emailVerified: json['email_verified'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'token': instance.token,
      'user_id': instance.userId,
      'email': instance.email,
      'email_verified': instance.emailVerified,
      'message': instance.message,
    };

VerifyTokenRequest _$VerifyTokenRequestFromJson(Map<String, dynamic> json) =>
    VerifyTokenRequest(idToken: json['id_token'] as String);

Map<String, dynamic> _$VerifyTokenRequestToJson(VerifyTokenRequest instance) =>
    <String, dynamic>{'id_token': instance.idToken};

VerifyTokenResponse _$VerifyTokenResponseFromJson(Map<String, dynamic> json) =>
    VerifyTokenResponse(
      uid: json['userId'] as String,
      email: json['email'] as String?,
      isValid: json['valid'] as bool,
      expired: json['expired'] as bool?,
    );

Map<String, dynamic> _$VerifyTokenResponseToJson(
  VerifyTokenResponse instance,
) => <String, dynamic>{
  'userId': instance.uid,
  'email': instance.email,
  'valid': instance.isValid,
  'expired': instance.expired,
};

ResendVerificationRequest _$ResendVerificationRequestFromJson(
  Map<String, dynamic> json,
) => ResendVerificationRequest(email: json['email'] as String);

Map<String, dynamic> _$ResendVerificationRequestToJson(
  ResendVerificationRequest instance,
) => <String, dynamic>{'email': instance.email};

VerifyEmailRequest _$VerifyEmailRequestFromJson(Map<String, dynamic> json) =>
    VerifyEmailRequest(email: json['email'] as String);

Map<String, dynamic> _$VerifyEmailRequestToJson(VerifyEmailRequest instance) =>
    <String, dynamic>{'email': instance.email};

ResendVerificationResponse _$ResendVerificationResponseFromJson(
  Map<String, dynamic> json,
) => ResendVerificationResponse(
  message: json['message'] as String,
  sent: json['sent'] as bool,
  attemptsRemaining: (json['attempts_remaining'] as num?)?.toInt(),
  blockedUntil: json['blocked_until'] as String?,
);

Map<String, dynamic> _$ResendVerificationResponseToJson(
  ResendVerificationResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'sent': instance.sent,
  'attempts_remaining': instance.attemptsRemaining,
  'blocked_until': instance.blockedUntil,
};

RateLimitErrorDetail _$RateLimitErrorDetailFromJson(
  Map<String, dynamic> json,
) => RateLimitErrorDetail(
  error: json['error'] as String,
  message: json['message'] as String,
  blockedUntil: json['blocked_until'] as String?,
);

Map<String, dynamic> _$RateLimitErrorDetailToJson(
  RateLimitErrorDetail instance,
) => <String, dynamic>{
  'error': instance.error,
  'message': instance.message,
  'blocked_until': instance.blockedUntil,
};

RateLimitErrorResponse _$RateLimitErrorResponseFromJson(
  Map<String, dynamic> json,
) => RateLimitErrorResponse(
  detail: RateLimitErrorDetail.fromJson(json['detail'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RateLimitErrorResponseToJson(
  RateLimitErrorResponse instance,
) => <String, dynamic>{'detail': instance.detail};
