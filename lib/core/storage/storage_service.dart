import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../errors/app_exception.dart';

/// Well-known storage keys. Centralized so no screen invents its own string
/// and collides with another.
abstract final class StorageKeys {
  static const session = 'session.v1';
  static const onboardingCompleted = 'onboarding_completed.v1';
  static const themeMode = 'theme_mode.v1';
  static const locale = 'locale.v1';
  static const mealLogEntries = 'meal_log_entries.v1';
  static const measurements = 'measurements.v1';
  static const notificationsRead = 'notifications_read.v1';
  static const healthProfile = 'health_profile.v1';
}

/// Key-value persistence abstraction. UI and repositories depend on THIS
/// interface; `SharedPrefsStorageService` is the production implementation
/// and fakes are trivial to build in tests.
abstract interface class StorageService {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);

  Future<bool?> readBool(String key);
  Future<void> writeBool(String key, bool value);

  Future<int?> readInt(String key);
  Future<void> writeInt(String key, int value);

  /// Decodes a JSON object previously stored with [writeMap].
  Future<Map<String, dynamic>?> readMap(String key);

  /// Encodes a JSON-serializable object as a single string value.
  Future<void> writeMap(String key, Map<String, dynamic> value);

  Future<bool> containsKey(String key);
  Future<void> remove(String key);
}

class SharedPrefsStorageService implements StorageService {
  SharedPrefsStorageService(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPrefsStorageService> init() async =>
      SharedPrefsStorageService(await SharedPreferences.getInstance());

  @override
  Future<String?> readString(String key) async => _prefs.getString(key);

  @override
  Future<void> writeString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<bool?> readBool(String key) async => _prefs.getBool(key);

  @override
  Future<void> writeBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<int?> readInt(String key) async => _prefs.getInt(key);

  @override
  Future<void> writeInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<Map<String, dynamic>?> readMap(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Stored value is not a JSON object');
    } catch (e) {
      // Corrupted payload: drop it rather than crash on every read.
      await _prefs.remove(key);
      throw StorageException('Corrupted stored value for $key', cause: e);
    }
  }

  @override
  Future<void> writeMap(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  @override
  Future<bool> containsKey(String key) async => _prefs.containsKey(key);

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}


/// In-memory [StorageService] for widget/unit tests and the no-setup
/// default in [AppDependencies.inMemory]. Data resets on every run.
class MemoryStorageService implements StorageService {
  final Map<String, Object> _data = {};

  @override
  Future<String?> readString(String key) async => _data[key] as String?;

  @override
  Future<void> writeString(String key, String value) async => _data[key] = value;

  @override
  Future<bool?> readBool(String key) async => _data[key] as bool?;

  @override
  Future<void> writeBool(String key, bool value) async => _data[key] = value;

  @override
  Future<int?> readInt(String key) async => _data[key] as int?;

  @override
  Future<void> writeInt(String key, int value) async => _data[key] = value;

  @override
  Future<Map<String, dynamic>?> readMap(String key) async {
    final raw = _data[key];
    if (raw is! String) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Stored value is not a JSON object');
    } catch (e) {
      _data.remove(key);
      throw StorageException('Corrupted stored value for $key', cause: e);
    }
  }

  @override
  Future<void> writeMap(String key, Map<String, dynamic> value) async => _data[key] = jsonEncode(value);

  @override
  Future<bool> containsKey(String key) async => _data.containsKey(key);

  @override
  Future<void> remove(String key) async => _data.remove(key);
}
