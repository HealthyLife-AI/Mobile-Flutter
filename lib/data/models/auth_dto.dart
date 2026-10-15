import '../../core/errors/app_exception.dart';
import '../../core/network/auth_tokens.dart';
import '../../domain/entities/auth_entities.dart';

/// Converts the auth endpoints' JSON (API guide sections 2–4) into domain
/// objects, and back for the on-device session cache.
///
/// Required fields throw [ParseException]. Optional fields become null. The
/// mapper never invents a token, an id or a user.
class AuthMapper {
  AuthMapper._();

  /// Used only when the server omits `expires_in`. The API always sends it.
  static const int _defaultExpiresIn = 900;

  /// Body of `POST /auth/login` and `PUT /me/password`: a token pair and the user.
  static ({AuthTokens tokens, PatientUser user}) signedInFromJson(
      Object? json) {
    final map = _asMap(json, 'sign-in response');
    return (
      tokens: tokensFromJson(map),
      user: userFromJson(map['user']),
    );
  }

  /// Body of `POST /auth/refresh` (a token pair, with no user) and the token
  /// fields of a sign-in response.
  static AuthTokens tokensFromJson(Object? json) {
    final map = _asMap(json, 'token response');
    return AuthTokens(
      accessToken: _requiredString(map, 'access_token'),
      refreshToken: _requiredString(map, 'refresh_token'),
      expiresIn: _optionalInt(map, 'expires_in') ?? _defaultExpiresIn,
    );
  }

  /// The `user` object (API guide 3.1), also returned by `GET /auth/me`.
  static PatientUser userFromJson(Object? json) {
    final map = _asMap(json, 'user');
    return PatientUser(
      id: _requiredInt(map, 'id'),
      name: _optionalString(map, 'name') ?? '',
      phone: _optionalString(map, 'phone'),
      role: _optionalString(map, 'role'),
      nutritionistId: _optionalInt(map, 'nutritionist_id'),
      subscriberId: _optionalInt(map, 'subscriber_id'),
      gender: _optionalString(map, 'gender'),
      patientCode: _optionalString(map, 'patient_code'),
      avatarUrl: _optionalString(map, 'avatar_url'),
      username: _optionalString(map, 'username'),
      passwordIsTemporary: map['password_is_temporary'] == true,
    );
  }

  /// `GET /me/consent`, or the consent part of a 409/403 body.
  static ConsentStatus consentFromJson(Object? json) =>
      ConsentStatus.fromJson(_asMap(json, 'consent response'));

  static Map<String, dynamic> userToJson(PatientUser user) => {
        'id': user.id,
        'name': user.name,
        'phone': user.phone,
        'role': user.role,
        'nutritionist_id': user.nutritionistId,
        'subscriber_id': user.subscriberId,
        'gender': user.gender,
        'patient_code': user.patientCode,
        'avatar_url': user.avatarUrl,
        'username': user.username,
        'password_is_temporary': user.passwordIsTemporary,
      };

  static Map<String, dynamic> tokensToJson(AuthTokens tokens) => {
        'access_token': tokens.accessToken,
        'refresh_token': tokens.refreshToken,
        'expires_in': tokens.expiresIn,
      };

  static Map<String, dynamic> sessionToJson(StoredSession session) => {
        'tokens': tokensToJson(session.tokens),
        'user': userToJson(session.user),
        'onboarding_completed': session.onboardingCompleted,
      };

  static StoredSession sessionFromJson(Object? json) {
    final map = _asMap(json, 'stored session');
    return StoredSession(
      tokens: tokensFromJson(map['tokens']),
      user: userFromJson(map['user']),
      onboardingCompleted: map['onboarding_completed'] == true,
    );
  }

  static Map<String, dynamic> _asMap(Object? value, String what) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw ParseException('Expected an object for $what');
  }

  static String _requiredString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is String && value.isNotEmpty) return value;
    throw ParseException('Missing string "$key"');
  }

  static String? _optionalString(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is String && value.isNotEmpty ? value : null;
  }

  static int _requiredInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is num) return value.toInt();
    throw ParseException('Missing integer "$key"');
  }

  static int? _optionalInt(Map<String, dynamic> map, String key) {
    final value = map[key];
    return value is num ? value.toInt() : null;
  }
}
