import '../../core/errors/result.dart';
import '../entities/notification_entities.dart';

/// Notifications feed with locally-persisted read state.
abstract interface class NotificationRepository {
  /// Feed groups with [NotificationEntry.unread] reflecting persisted
  /// read state (not just what the mock feed ships with).
  Future<Result<List<NotificationDateGroup>>> getGroups();

  Future<Result<void>> markRead(String id);

  Future<Result<void>> markAllRead(List<String> ids);
}
