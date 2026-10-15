import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted key-value storage for anything that identifies the patient:
/// tokens and the cached user. Backed by Keychain (iOS) and EncryptedSharedPreferences
/// with an Android Keystore key (Android).
///
/// Preferences (theme, language) stay in [StorageService]: they are not
/// sensitive and do not need encryption.
abstract interface class SecureVault {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class FlutterSecureVault implements SecureVault {
  FlutterSecureVault([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// In-memory vault for tests and for the fallback graph used when the
/// platform keystore is unavailable. Nothing survives a restart.
class MemorySecureVault implements SecureVault {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}
