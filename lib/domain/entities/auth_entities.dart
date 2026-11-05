import 'package:flutter/foundation.dart';

import '../../core/network/auth_tokens.dart';

/// The patient, as returned by `POST /auth/login` and `GET /auth/me`
/// (API guide section 3.1).
@immutable
class PatientUser {
  const PatientUser({
    required this.id,
    required this.name,
    this.phone,
    this.role,
    this.nutritionistId,
    this.subscriberId,
    this.gender,
    this.patientCode,
    this.avatarUrl,
    this.username,
    this.passwordIsTemporary = false,
  });

  final int id;
  final String name;
  final String? phone;
  final String? role;
  final int? nutritionistId;
  final int? subscriberId;

  /// `male`, `female` or null. Use it for Arabic grammar; null → neutral form.
  final String? gender;
  final String? patientCode;
  final String? avatarUrl;

  /// Null only for patients created before usernames existed.
  final String? username;

  /// True until the patient chooses their own password: show a gentle reminder.
  final bool passwordIsTemporary;

  PatientUser copyWith({bool? passwordIsTemporary, String? name}) =>
      PatientUser(
        id: id,
        name: name ?? this.name,
        phone: phone,
        role: role,
        nutritionistId: nutritionistId,
        subscriberId: subscriberId,
        gender: gender,
        patientCode: patientCode,
        avatarUrl: avatarUrl,
        username: username,
        passwordIsTemporary: passwordIsTemporary ?? this.passwordIsTemporary,
      );
}

/// What is kept on the device after sign-in. Stored encrypted.
@immutable
class StoredSession {
  const StoredSession({
    required this.tokens,
    required this.user,
    this.onboardingCompleted = false,
  });

  final AuthTokens tokens;
  final PatientUser user;

  /// Local flag: the post-sign-in wizard (measurements, health, notifications)
  /// was finished on this device.
  final bool onboardingCompleted;

  StoredSession copyWith({
    AuthTokens? tokens,
    PatientUser? user,
    bool? onboardingCompleted,
  }) =>
      StoredSession(
        tokens: tokens ?? this.tokens,
        user: user ?? this.user,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      );
}

/// Privacy-policy state from `GET /me/consent`, or from a `403 consent_required`
/// body (which has no `required` key, so it defaults to true).
@immutable
class ConsentStatus {
  const ConsentStatus({
    required this.isRequired,
    this.currentVersion,
    this.policyUrl,
  });

  final bool isRequired;
  final String? currentVersion;

  /// May be null: the screen then shows no link but still allows accepting.
  final String? policyUrl;

  factory ConsentStatus.fromJson(Map<String, dynamic> json) => ConsentStatus(
        isRequired: json['required'] is bool ? json['required'] as bool : true,
        currentVersion: json['current_version'] as String?,
        policyUrl: json['policy_url'] as String?,
      );
}

/// The «انتهت المتابعة» state. Built only from the `403 follow_up_ended` body
/// (API guide section 2.4). Every field except [message] can be null, and the
/// screen hides whatever is missing.
@immutable
class FollowUpEnded {
  const FollowUpEnded({
    this.message,
    this.nutritionistName,
    this.whatsappNumber,
    this.weeksFollowed,
    this.adherencePercent,
  });

  /// Used when the body could not be read at all.
  static const FollowUpEnded fallback = FollowUpEnded();

  final String? message;
  final String? nutritionistName;

  /// E.164-style, for example `+970599123456`. Hide the WhatsApp button when null.
  final String? whatsappNumber;
  final int? weeksFollowed;

  /// Hide the adherence figure when null.
  final double? adherencePercent;

  factory FollowUpEnded.fromJson(Map<String, dynamic> json) {
    final nutritionist = json['nutritionist'];
    final name = nutritionist is Map ? nutritionist['name'] : null;
    final whatsapp =
        nutritionist is Map ? nutritionist['whatsapp_number'] : null;
    return FollowUpEnded(
      message: json['message'] as String?,
      nutritionistName: name is String ? name : null,
      whatsappNumber:
          whatsapp is String && whatsapp.isNotEmpty ? whatsapp : null,
      weeksFollowed: (json['weeks_followed'] as num?)?.toInt(),
      adherencePercent: (json['adherence_percent'] as num?)?.toDouble(),
    );
  }
}
