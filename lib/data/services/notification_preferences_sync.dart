import '../../core/errors/app_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/device_timezone.dart';
import '../../domain/repositories/preferences_sync.dart';
import '../../domain/repositories/settings_repository.dart';

/// `PUT /me/notification-preferences` with the patient's app language and,
/// when the device's timezone can be read, its IANA name (guide 10.5).
///
/// The request is flat and accepts any subset of fields. A timezone name the
/// server does not know gets `422 invalid_timezone`. The sync then sends the
/// same request once more without `timezone`. Without a timezone the server
/// uses the clinic's, which is the right fallback for patients in Palestine.
///
/// The sync never throws. A failure is logged and the app goes on.
class NotificationPreferencesSync implements PreferencesSync {
  NotificationPreferencesSync({
    required ApiClient api,
    required SettingsRepository settings,
    required DeviceTimezone timezone,
  })  : _api = api,
        _settings = settings,
        _timezone = timezone;

  final ApiClient _api;
  final SettingsRepository _settings;
  final DeviceTimezone _timezone;

  static const DefaultAppLogger _log = DefaultAppLogger();

  /// The timezone the last successful sync sent (null when none was readable),
  /// and whether a sync has succeeded since the app started.
  String? _sentZone;
  bool _sentOnce = false;

  /// The app language until the patient chooses one (Arabic, see SettingsCubit).
  static const String _defaultLocale = 'ar';

  @override
  Future<void> sync() async {
    try {
      final locale = (await _settings.getLocale()).valueOrNull?.languageCode ??
          _defaultLocale;
      final zone = await _readZone();
      try {
        await _put(locale: locale, zone: zone);
      } on ApiException catch (error) {
        if (zone == null || error.code != 'invalid_timezone') rethrow;
        _log.warn(
            'The server rejected the device timezone; sending again without it',
            error: error);
        await _put(locale: locale, zone: null);
      }
      _sentZone = zone;
      _sentOnce = true;
    } catch (error) {
      _log.warn('Could not sync notification preferences', error: error);
    }
  }

  /// Sends the settings again only when the device timezone differs from the one
  /// the last successful sync sent. A timezone that cannot be read is treated as
  /// unchanged, so nothing is sent for it.
  @override
  Future<void> syncIfZoneChanged() async {
    final zone = await _readZone();
    if (zone == null) return;
    if (_sentOnce && zone == _sentZone) return;
    await sync();
  }

  /// The device's IANA name, or null when it is blank or cannot be read.
  Future<String?> _readZone() async {
    try {
      final name = (await _timezone.ianaName())?.trim();
      return name == null || name.isEmpty ? null : name;
    } catch (error) {
      _log.warn('The device timezone could not be read', error: error);
      return null;
    }
  }

  Future<void> _put({required String locale, required String? zone}) async {
    await _api.put(
      'me/notification-preferences',
      body: <String, dynamic>{
        'locale': locale,
        if (zone != null) 'timezone': zone,
      },
    );
  }
}
