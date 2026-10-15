import '../../core/logging/app_logger.dart';
import '../../domain/repositories/notification_repository.dart';

/// Marks a pushed notification read (API guide 10.4).
///
/// The inbox does the work: it keeps the row read on this device and sends
/// `POST /me/notifications/{id}/read` (10.2), so a tapped push and a tapped
/// inbox row reach the server the same way, once. Never throws.
class NotificationReadReceipt {
  NotificationReadReceipt({required NotificationRepository inbox})
      : _inbox = inbox;

  final NotificationRepository _inbox;

  static const DefaultAppLogger _log = DefaultAppLogger();

  Future<void> send(String notificationId) async {
    final result = await _inbox.markRead(notificationId);
    if (!result.isSuccess) {
      _log.warn('Could not mark the notification read',
          error: result.failureOrNull);
    }
  }
}
