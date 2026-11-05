import 'package:flutter/widgets.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/entities/measurement_entities.dart';
import '../../domain/repositories/notification_preferences_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/weigh_in_reminder_rules.dart';
import '../../l10n/generated/app_localizations.dart';
import 'local_reminder_notifications.dart';

/// The weekly weigh-in reminder, scheduled on the device (API guide 10.6:
/// only while `measurements` is on, and respecting quiet hours).
///
/// [plan] is called whenever the readings are read and whenever the settings
/// change, so the reminder always follows the latest reading. Never throws.
class WeighInReminder {
  WeighInReminder({
    required ReminderNotifications notifications,
    required NotificationPreferencesRepository preferences,
    required SettingsRepository settings,
    DateTime Function()? clock,
  })  : _notifications = notifications,
        _preferences = preferences,
        _settings = settings,
        _clock = clock ?? DateTime.now;

  final ReminderNotifications _notifications;
  final NotificationPreferencesRepository _preferences;
  final SettingsRepository _settings;
  final DateTime Function() _clock;

  static const DefaultAppLogger _log = DefaultAppLogger();

  /// Replaces the reminder with one for [snapshot]'s next due day, or removes
  /// it when none is due (no reading, or measurement notifications off).
  Future<void> plan(MeasurementSnapshot snapshot) async {
    try {
      final at = weighInReminderAt(
        snapshot: snapshot,
        preferences: await _preferences.known(),
        now: _clock(),
      );
      await _notifications.cancel(weighInNotificationId);
      if (at == null) return;
      final locale =
          (await _settings.getLocale()).valueOrNull ?? const Locale('ar');
      final copy = lookupAppLocalizations(locale);
      await _notifications.schedule(
        id: weighInNotificationId,
        at: at,
        channelId: weighInChannelId,
        channelName: copy.weighInReminderChannel,
        title: copy.weighInReminderTitle,
        body: copy.weighInReminderBody,
      );
    } catch (error) {
      _log.warn('The weigh-in reminder could not be planned', error: error);
    }
  }
}
