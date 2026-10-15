import '../../core/config/app_config.dart';
import '../../core/errors/app_exception.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/notification_entities.dart';
import '../mock/notification_mock_data.dart';
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

/// The demo feed. Reads are not sent anywhere.
class MockNotificationDataSource implements NotificationDataSource {
  const MockNotificationDataSource({this.latency = AppConfig.mockLatency});

  final Duration latency;

  /// The whole demo feed is page 1.
  @override
  Future<NotificationPage> fetchPage(int page) async {
    await Future<void>.delayed(latency);
    if (page > 1) return const NotificationPage([]);
    // Defensive copies: repositories must never mutate the shared mock feed.
    return NotificationPage(NotificationMockData.groups
        .map((g) => NotificationDateGroup(
            label: g.label, items: List.unmodifiable(g.items)))
        .toList());
  }

  @override
  Future<void> markRead(String id) async {}

  @override
  Future<void> markAllRead() async {}
}
