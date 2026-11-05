import '../../core/network/api_client.dart';

/// The auth endpoints (API guide sections 2–4 and 13). Returns the raw JSON;
/// [AuthMapper] turns it into domain objects, so this class knows nothing of
/// the domain.
///
/// Login, refresh and logout send no bearer token (`auth: false`).
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);

  final ApiClient _api;

  /// `POST /auth/login`. The password is sent exactly as typed.
  Future<dynamic> login({required String username, required String password}) =>
      _api.post(
        'auth/login',
        body: {'username': username, 'password': password},
        auth: false,
      );

  /// `POST /auth/refresh`. Refresh tokens are single use.
  Future<dynamic> refresh(String refreshToken) => _api.post(
        'auth/refresh',
        body: {'refresh_token': refreshToken},
        auth: false,
      );

  /// `POST /auth/logout`. Always answers 200 on the server.
  Future<dynamic> logout(String refreshToken) => _api.post(
        'auth/logout',
        body: {'refresh_token': refreshToken},
        auth: false,
      );

  /// `GET /auth/me`.
  Future<dynamic> me() => _api.get('auth/me');

  /// `GET /me/consent`.
  Future<dynamic> consent() => _api.get('me/consent');

  /// `POST /me/consent` with the policy version the patient was shown.
  Future<dynamic> acceptConsent(String version) =>
      _api.post('me/consent', body: {'version': version});

  /// `PUT /me/password`. The server expects the new password twice.
  Future<dynamic> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _api.put('me/password', body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      });

  /// `DELETE /me/account` with the current password in the body. Answers 204.
  Future<void> deleteAccount(String password) async {
    await _api.delete('me/account', body: {'password': password});
  }
}
