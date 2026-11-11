import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/notification_entities.dart';
import '../models/json_read.dart';
import '../models/notification_dto.dart';

/// The notification inbox (API guide 10.2).
abstract interface class NotificationDataSource {
  /// One page of rows, grouped by local day, newest first. Page 1 is the
  /// newest.
  Future<NotificationPage> fetchPage(int page);

  /// `POST /me/notifications/{id}/read`. Safe to repeat.
  Future<void> markRead(String id);

  /// `POST /me/notifications/read-all`.
  Future<void> markAllRead();

  /// `GET /me/notifications/unread-count`: unread rows on every page. Null
  /// when the source cannot tell.
  Future<int?> unreadCount();
}

/// The inbox from the server: `GET /me/notifications?page=` (20 per page,
/// newest first, `meta: {current_page, last_page}`, 1.6).
class HttpNotificationDataSource implements NotificationDataSource {
  HttpNotificationDataSource(this._api);

  final ApiClient _api;

  @override
  Future<NotificationPage> fetchPage(int page) async {
    final raw = await _api.get('me/notifications', query: {'page': '$page'});
    final rows = raw is Map ? raw['data'] : null;
    if (rows is! List) {
      throw const ParseException('The notification inbox is not a list');
    }
    final entries = [
      for (final row in rows.whereType<Map>())
        NotificationDto.fromJson(Map<String, dynamic>.from(row)),
    ].whereType<NotificationEntry>();
    final meta = raw is Map ? raw['meta'] : null;
    final current = meta is Map ? meta['current_page'] : null;
    final last = meta is Map ? meta['last_page'] : null;
    return NotificationPage(
      groupByDay(entries),
      hasMore: current is num && last is num && current < last,
    );
  }

  /// The id can come from a push payload, so it is encoded and cannot change
  /// the path.
  @override
  Future<void> markRead(String id) =>
      _api.post('me/notifications/${Uri.encodeComponent(id)}/read');

  @override
  Future<void> markAllRead() => _api.post('me/notifications/read-all');

  /// `{"unread": 3}` (10.2).
  @override
  Future<int?> unreadCount() async {
    final raw = await _api.get('me/notifications/unread-count');
    final count = jsonInt(raw is Map ? raw['unread'] : null);
    if (count == null) {
      throw const ParseException('The unread count is not a number');
    }
    return count < 0 ? 0 : count;
  }

  /// Rows in order, one group per local day. A row without a time joins the
  /// group before it.
  static List<NotificationDateGroup> groupByDay(
      Iterable<NotificationEntry> entries) {
    final groups = <NotificationDateGroup>[];
    DateTime? day;
    var items = <NotificationEntry>[];
    void close() {
      if (items.isNotEmpty) {
        groups.add(NotificationDateGroup(label: '', day: day, items: items));
      }
    }

    for (final entry in entries) {
      final at = entry.createdAt;
      final entryDay = at == null ? day : DateTime(at.year, at.month, at.day);
      if (items.isNotEmpty && entryDay != day) {
        close();
        items = <NotificationEntry>[];
      }
      day = entryDay;
      items.add(entry);
    }
    close();
    return groups;
  }
}
