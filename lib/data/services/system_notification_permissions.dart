import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import '../../core/logging/app_logger.dart';
import '../../domain/repositories/notification_permissions.dart';

/// Reads and requests the notification permission through
/// [FirebaseMessaging] (already initialised by the app), and opens the OS
/// app-settings page through `permission_handler`.
///
/// firebase_messaging is used for the permission itself rather than
/// permission_handler because it works on Android and iOS without extra native
/// setup, and it already reflects the Android 13+ POST_NOTIFICATIONS state.
///
/// The two Firebase calls are behind [readStatus]/[requestPermission] so the
/// mapping and the failure handling can be tested without Firebase.
///
/// Everything is best-effort: a missing Firebase or an unsupported platform is
/// logged and reported as "not determined", never thrown, so the settings
/// screen can always render.
class SystemNotificationPermissions implements NotificationPermissions {
  SystemNotificationPermissions({
    Future<AuthorizationStatus> Function()? readStatus,
    Future<AuthorizationStatus> Function()? requestPermission,
    Future<bool> Function()? openSettings,
  })  : _readStatus = readStatus ?? _defaultReadStatus,
        _requestPermission = requestPermission ?? _defaultRequestPermission,
        _openSettings = openSettings ?? ph.openAppSettings;

  static const DefaultAppLogger _log = DefaultAppLogger();

  final Future<AuthorizationStatus> Function() _readStatus;
  final Future<AuthorizationStatus> Function() _requestPermission;
  final Future<bool> Function() _openSettings;

  static Future<AuthorizationStatus> _defaultReadStatus() async =>
      (await FirebaseMessaging.instance.getNotificationSettings())
          .authorizationStatus;

  static Future<AuthorizationStatus> _defaultRequestPermission() async =>
      (await FirebaseMessaging.instance.requestPermission())
          .authorizationStatus;

  @override
  Future<NotificationPermissionStatus> status() async {
    try {
      return _map(await _readStatus());
    } catch (error) {
      _log.warn('Could not read the notification permission', error: error);
      return NotificationPermissionStatus.notDetermined;
    }
  }

  @override
  Future<NotificationPermissionStatus> request() async {
    try {
      return _map(await _requestPermission());
    } catch (error) {
      _log.warn('Could not request the notification permission', error: error);
      return NotificationPermissionStatus.notDetermined;
    }
  }

  @override
  Future<bool> openSystemSettings() async {
    try {
      return await _openSettings();
    } catch (error) {
      _log.warn('Could not open the system notification settings',
          error: error);
      return false;
    }
  }

  static NotificationPermissionStatus _map(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return NotificationPermissionStatus.granted;
      case AuthorizationStatus.denied:
        return NotificationPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return NotificationPermissionStatus.notDetermined;
    }
  }
}
