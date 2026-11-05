import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../sync/offline_queue.dart';
import 'app_navigator.dart';

/// Tells the patient that the server refused a reading saved offline (API
/// guide 14.2). The queue logs the reason. The patient sees one sentence,
/// whatever the reason was.
///
/// The snackbar goes on the root navigator, so it shows over whatever screen
/// is up. If no screen is up yet, nothing is shown and the notice is lost.
void showDroppedWriteNotice(DroppedWrite write) {
  final context = appNavigatorKey.currentContext;
  if (context == null || !context.mounted) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.showSnackBar(
    SnackBar(
      content: Text(context.l10n.offlineWriteDropped),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 8),
    ),
  );
}
