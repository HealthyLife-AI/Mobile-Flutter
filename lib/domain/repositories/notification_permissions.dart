/// The OS-level permission that lets the app show notifications.
///
/// Separate from [PushRegistrar]: registering the device's push token and
/// asking the person to *allow* notifications are different concerns. The
/// token can be registered while the permission is undecided; only the OS
/// controls whether anything is actually shown.
enum NotificationPermissionStatus {
  /// The person has never been asked (the OS would still show the prompt).
  notDetermined,

  /// Asked before and refused, or disabled later in the OS settings. The OS
  /// will not show the prompt again — the person must change it in settings.
  denied,

  /// Notifications are allowed.
  granted,
}

abstract interface class NotificationPermissions {
  /// Reads the current status from the OS. Never throws: when the platform
  /// cannot answer (no Firebase, unsupported platform) it reports
  /// [NotificationPermissionStatus.notDetermined].
  Future<NotificationPermissionStatus> status();

  /// Asks the OS to show its permission prompt. On a status of `denied` the
  /// OS does not prompt again and returns the denied status unchanged.
  Future<NotificationPermissionStatus> request();

  /// Opens the app's page in the OS settings, where a denied permission can be
  /// re-enabled. Returns true only when the settings page was actually opened.
  Future<bool> openSystemSettings();
}
