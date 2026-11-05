import 'auth_tokens.dart';

/// Where the network stack reads and writes the signed-in patient's tokens.
///
/// Implemented by the data layer on top of encrypted storage, so `core/network`
/// never touches the disk and tests can pass an in-memory double.
abstract interface class TokenStore {
  /// Current tokens, or null when nobody is signed in.
  Future<AuthTokens?> readTokens();

  /// Replaces the stored tokens. Does nothing when nobody is signed in.
  Future<void> saveTokens(AuthTokens tokens);

  /// Forgets the session (tokens and cached user).
  Future<void> clear();
}
