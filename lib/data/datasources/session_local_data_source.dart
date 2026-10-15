import 'dart:convert';

import '../../core/errors/app_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/auth_tokens.dart';
import '../../core/network/token_store.dart';
import '../../core/storage/secure_vault.dart';
import '../../domain/entities/auth_entities.dart';
import '../models/auth_dto.dart';

/// The signed-in session on this device: the token pair, the cached user and
/// the onboarding flag. Stored as one encrypted JSON document in [SecureVault].
///
/// It implements [TokenStore], so the network stack reads and rotates tokens
/// without knowing about the rest of the session. The session is kept in
/// memory after the first read, because the auth interceptor reads tokens on
/// every request.
class SessionLocalDataSource implements TokenStore {
  SessionLocalDataSource(this._vault, {this.onCleared});

  /// Runs whenever the session is cleared, to forget the patient's data on
  /// this device (API guide 2.5).
  final Future<void> Function()? onCleared;

  /// Versioned key. Sessions from the pre-launch invite flow are not migrated:
  /// those patients sign in once with their username.
  static const String _key = 'auth.session.v2';

  final SecureVault _vault;

  StoredSession? _cache;
  bool _loaded = false;

  /// The stored session, or null when nobody is signed in.
  Future<StoredSession?> read() async {
    if (_loaded) return _cache;
    final raw = await _readVault();
    if (raw == null) {
      _cache = null;
    } else {
      try {
        _cache = AuthMapper.sessionFromJson(jsonDecode(raw));
      } on FormatException {
        await _forgetCorrupt();
      } on ParseException {
        await _forgetCorrupt();
      }
    }
    _loaded = true;
    return _cache;
  }

  Future<String?> _readVault() async {
    try {
      return await _vault.read(_key);
    } catch (e) {
      throw StorageException('Could not read the session', cause: e);
    }
  }

  /// Replaces the whole session.
  Future<void> save(StoredSession session) async {
    try {
      await _vault.write(_key, jsonEncode(AuthMapper.sessionToJson(session)));
    } catch (e) {
      throw StorageException('Could not save the session', cause: e);
    }
    _cache = session;
    _loaded = true;
  }

  @override
  Future<AuthTokens?> readTokens() async => (await read())?.tokens;

  /// Keeps the cached user and flags, and replaces only the tokens. Does
  /// nothing when nobody is signed in.
  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    final current = await read();
    if (current == null) return;
    await save(current.copyWith(tokens: tokens));
  }

  /// Forgets the session. The memory copy is dropped first, so the app is
  /// signed out at once even if the encrypted entry cannot be deleted.
  @override
  Future<void> clear() async {
    _cache = null;
    _loaded = true;
    await _forgetPatientData();
    try {
      await _vault.delete(_key);
    } catch (e) {
      throw StorageException('Could not clear the session', cause: e);
    }
  }

  /// Forgets the patient's data along with the session. A failure is logged
  /// and does not stop sign-out.
  Future<void> _forgetPatientData() async {
    try {
      await onCleared?.call();
    } catch (error) {
      const DefaultAppLogger()
          .warn('Patient data could not be cleared', error: error);
    }
  }

  /// An unreadable entry counts as signed out. It must not crash start-up.
  Future<void> _forgetCorrupt() async {
    _cache = null;
    await _forgetPatientData();
    try {
      await _vault.delete(_key);
    } catch (_) {
      // Still signed out in memory; the entry is retried on the next launch.
    }
  }
}
