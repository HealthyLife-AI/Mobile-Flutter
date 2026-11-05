import 'package:flutter/widgets.dart';

import '../../domain/repositories/settings_repository.dart';
import '../../l10n/generated/app_localizations.dart';
import 'local_reminder_notifications.dart';

/// Creates the Android channel that the server's pushes are shown in (API
/// guide 10.4), named in the app's language. Run again at the next start, it
/// renames the channel after a language change.
Future<void> createPushChannel(
  FlutterReminderNotifications notifications,
  SettingsRepository settings,
) async {
  final locale =
      (await settings.getLocale()).valueOrNull ?? const Locale('ar');
  await notifications.createChannel(
    id: pushChannelId,
    name: lookupAppLocalizations(locale).pushChannelName,
  );
}
