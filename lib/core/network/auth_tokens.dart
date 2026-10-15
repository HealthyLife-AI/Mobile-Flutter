import 'package:flutter/foundation.dart';

/// One access/refresh pair from `POST /auth/login`, `POST /auth/refresh` or
/// `PUT /me/password`. Refresh tokens are single use: always store the new
/// pair as soon as it arrives.
@immutable
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn = 900,
  });

  final String accessToken;
  final String refreshToken;

  /// Seconds the access token stays valid (900 = 15 minutes).
  final int expiresIn;

  @override
  String toString() =>
      'AuthTokens(expiresIn: $expiresIn)'; // never print tokens
}
