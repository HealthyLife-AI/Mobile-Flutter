import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import '../models/notification_preferences_dto.dart';

/// The notification settings on the server (API guide 10.5). The last answer
/// is kept on the device, for the settings screen offline and for planning the
/// device's own reminders. Cleared at sign-out (2.5).
class NotificationPreferencesRepositoryImpl
    implements NotificationPreferencesRepository, PatientCache {
  NotificationPreferencesRepositoryImpl(this._storage, this._api);

  static const String _path = 'me/notification-preferences';
  static const DefaultAppLogger _log = DefaultAppLogger();

  final StorageService _storage;
  final ApiClient _api;

  @override
  Future<Result<NotificationPreferences>> get() => guard(() async {
        try {
          return await _remember(await _api.get(_path));
        } on NetworkException {
          final kept = await _remembered();
          if (kept == null) rethrow;
          return kept;
        }
      });

  @override
  Future<Result<NotificationPreferences>> update(
          NotificationPreferences preferences) =>
      guard(() async => _remember(await _api.put(_path,
          body: NotificationPreferencesDto.toRequest(preferences))));

  @override
  Future<NotificationPreferences> known() async =>
      await _remembered() ?? const NotificationPreferences();

  @override
  Future<void> forgetPatientData() =>
      _storage.remove(StorageKeys.notificationPreferences);

  /// Reads the answer and keeps it. A failure to keep the copy does not fail
  /// a request that succeeded.
  Future<NotificationPreferences> _remember(Object? raw) async {
    if (raw is! Map) {
      throw const ParseException('The notification settings are not an object');
    }
    final preferences =
        NotificationPreferencesDto.fromJson(Map<String, dynamic>.from(raw));
    try {
      await _storage.writeMap(StorageKeys.notificationPreferences,
          NotificationPreferencesDto.toJson(preferences));
    } on Object catch (error) {
      _log.warn('The notification settings could not be kept on this device',
          error: error);
    }
    return preferences;
  }

  Future<NotificationPreferences?> _remembered() async {
    try {
      final raw = await _storage.readMap(StorageKeys.notificationPreferences);
      return raw == null ? null : NotificationPreferencesDto.fromJson(raw);
    } on Object catch (error) {
      _log.warn('The kept notification settings could not be read',
          error: error);
      return null;
    }
  }
}
