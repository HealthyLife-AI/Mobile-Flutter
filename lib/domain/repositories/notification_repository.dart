import '../../core/errors/result.dart';
import '../entities/notification_entities.dart';

/// Notifications feed with locally-persisted read state.
abstract interface class NotificationRepository {
  /// One page of the feed (page 1 is the newest), with
  /// [NotificationEntry.unread] reflecting the persisted read state.
  Future<Result<NotificationPage>> getPage(int page);

  Future<Result<void>> markRead(String id);

  Future<Result<void>> markAllRead(List<String> ids);

  /// Unread rows on every page, from the server (API guide 10.2). Null when
  /// the count is not known; the screens then count the rows they have.
  Future<Result<int?>> unreadCount();
}
