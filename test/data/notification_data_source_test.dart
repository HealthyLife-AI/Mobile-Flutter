import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/data/datasources/notification_data_source.dart';
import 'package:healthylife_ai/data/models/notification_dto.dart';
import 'package:healthylife_ai/domain/entities/notification_entities.dart';

/// Answers `GET me/notifications` with [inbox] and records every POST.
class _InboxApi implements ApiClient {
  _InboxApi([this.inbox]);

  final Object? inbox;
  final List<String> gets = [];
  final List<Map<String, dynamic>?> queries = [];
  final List<String> posts = [];

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    gets.add(path);
    queries.add(query);
    return inbox;
  }

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    posts.add(path);
    return null;
  }

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);
}

/// A row shaped like API guide 10.2.
Map<String, dynamic> _row(
  Object? id, {
  String category = 'meals',
  String type = 'meal_reminder',
  String? createdAt = '2026-10-15T09:30:00Z',
  String? updatedAt,
  String? readAt,
  Map<String, dynamic>? data,
}) =>
    {
      'id': id,
      'category': category,
      'type': type,
      'title': '  وقت الغداء  ',
      'body': 'سجّل وجبتك',
      'data': data ?? <String, dynamic>{},
      'read_at': readAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };

NotificationEntry _at(String id, DateTime? at) => NotificationEntry(
      id: id,
      category: NotificationCategory.other,
      variant: NotificationVariant.plain,
      title: 't',
      body: 'b',
      time: '',
      emoji: '🔔',
      unread: true,
      createdAt: at,
    );

void main() {
  group('NotificationDto', () {
    test('reads a server row', () {
      final entry = NotificationDto.fromJson(_row(41))!;

      expect(entry.id, '41');
      expect(entry.category, NotificationCategory.meals);
      expect(entry.variant, NotificationVariant.plain);
      expect(entry.title, 'وقت الغداء');
      expect(entry.body, 'سجّل وجبتك');
      expect(entry.type, 'meal_reminder');
      expect(entry.unread, isTrue);
      expect(entry.createdAt, DateTime.utc(2026, 10, 15, 9, 30).toLocal());
      expect(entry.createdAt!.isUtc, isFalse);
    });

    test('a row with read_at is read', () {
      final entry =
          NotificationDto.fromJson(_row(1, readAt: '2026-10-15T10:00:00Z'))!;
      expect(entry.unread, isFalse);
    });

    test('maps every server category', () {
      NotificationCategory of(String c) =>
          NotificationDto.fromJson(_row(1, category: c))!.category;

      expect(of('meals'), NotificationCategory.meals);
      expect(of('measurements'), NotificationCategory.measurements);
      expect(of('nutritionist'), NotificationCategory.nutritionist);
      expect(of('plan'), NotificationCategory.planUpdates);
      expect(of('system'), NotificationCategory.other);
      expect(of('something_new'), NotificationCategory.other);
    });

    test('a refreshed row shows its newer time', () {
      final entry = NotificationDto.fromJson(_row(1,
          createdAt: '2026-10-14T08:00:00Z',
          updatedAt: '2026-10-15T12:00:00Z'))!;
      expect(entry.createdAt, DateTime.utc(2026, 10, 15, 12).toLocal());
    });

    test('keeps the review a note points to', () {
      final entry = NotificationDto.fromJson(_row(1,
          category: 'nutritionist',
          type: 'review_new',
          data: {'review_id': 7}))!;
      expect(entry.reviewId, '7');
    });

    test('a row without an id is dropped', () {
      expect(NotificationDto.fromJson(_row(null)), isNull);
    });
  });

  group('HttpNotificationDataSource', () {
    test('reads the first page and groups it by local day', () async {
      final api = _InboxApi({
        'data': [
          _row(3, createdAt: '2026-10-15T09:00:00'),
          _row(2, createdAt: '2026-10-15T07:00:00'),
          _row(1, createdAt: '2026-10-13T20:00:00'),
        ],
        'meta': {'current_page': 1, 'last_page': 1},
      });

      final groups =
          (await HttpNotificationDataSource(api).fetchPage(1)).groups;

      expect(api.gets, ['me/notifications']);
      expect(groups.map((g) => g.day),
          [DateTime(2026, 10, 15), DateTime(2026, 10, 13)]);
      expect(groups.map((g) => g.items.map((e) => e.id).toList()), [
        ['3', '2'],
        ['1'],
      ]);
    });

    test('an empty inbox is no groups', () async {
      final page = await HttpNotificationDataSource(
              _InboxApi({'data': <Object>[], 'meta': <String, Object>{}}))
          .fetchPage(1);
      expect(page.groups, isEmpty);
      expect(page.hasMore, isFalse);
    });

    test('asks for the page and reads whether older pages exist', () async {
      final api = _InboxApi({
        'data': [_row(1)],
        'meta': {'current_page': 2, 'last_page': 3, 'total': 47},
      });

      final page = await HttpNotificationDataSource(api).fetchPage(2);

      expect(api.queries.single, {'page': '2'});
      expect(page.hasMore, isTrue);
    });

    test('the last page has nothing older', () async {
      final page = await HttpNotificationDataSource(_InboxApi({
        'data': [_row(1)],
        'meta': {'current_page': 3, 'last_page': 3},
      })).fetchPage(3);
      expect(page.hasMore, isFalse);
    });

    test('a reply that is not an inbox is a parse error', () async {
      await expectLater(
        HttpNotificationDataSource(_InboxApi(null)).fetchPage(1),
        throwsA(isA<ParseException>()),
      );
    });

    test('marks one row and all rows read on the server', () async {
      final api = _InboxApi();
      final source = HttpNotificationDataSource(api);

      await source.markRead('12');
      await source.markAllRead();

      expect(
          api.posts, ['me/notifications/12/read', 'me/notifications/read-all']);
    });

    test('encodes the id so it cannot change the path', () async {
      final api = _InboxApi();

      await HttpNotificationDataSource(api).markRead('../me');

      expect(api.posts.single, 'me/notifications/..%2Fme/read');
    });

    test('an older page joins the day split across the page break', () {
      final shown = HttpNotificationDataSource.groupByDay([
        _at('a', DateTime(2026, 10, 15, 9)),
        _at('b', DateTime(2026, 10, 14, 20)),
      ]);
      final older = HttpNotificationDataSource.groupByDay([
        _at('b', DateTime(2026, 10, 14, 20)), // moved down a page
        _at('c', DateTime(2026, 10, 14, 8)),
        _at('d', DateTime(2026, 10, 12, 8)),
      ]);

      final merged = appendOlderNotifications(shown, older);

      expect(merged.map((g) => g.items.map((e) => e.id).toList()), [
        ['a'],
        ['b', 'c'],
        ['d'],
      ]);
    });

    test('a row without a time joins the group before it', () {
      final groups = HttpNotificationDataSource.groupByDay([
        _at('a', DateTime(2026, 10, 15, 9)),
        _at('b', null),
        _at('c', DateTime(2026, 10, 14, 9)),
      ]);
      expect(groups.map((g) => g.items.map((e) => e.id).toList()), [
        ['a', 'b'],
        ['c'],
      ]);
    });
  });
}
