import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/domain/entities/notification_entities.dart';
import 'package:healthylife_ai/domain/repositories/notification_repository.dart';
import 'package:healthylife_ai/presentation/bloc/notifications/notifications_cubit.dart';

NotificationEntry _entry(String id, {bool unread = true}) => NotificationEntry(
      id: id,
      category: NotificationCategory.other,
      variant: NotificationVariant.plain,
      title: id,
      body: 'b',
      time: 'now',
      emoji: '⭐',
      unread: unread,
    );

/// A repository the test controls, so the cubit's status transitions and its
/// optimistic read handling are what is under test.
class _FakeRepository implements NotificationRepository {
  _FakeRepository(this.groups);

  List<NotificationDateGroup> groups;
  Failure? failWith;
  final List<String> readIds = [];
  final List<List<String>> bulk = [];

  /// Pages after the first, by page number. Page 1 is [groups].
  final Map<int, List<NotificationDateGroup>> older = {};
  final List<int> pagesAsked = [];

  @override
  Future<Result<NotificationPage>> getPage(int page) async {
    pagesAsked.add(page);
    if (failWith != null) return Failed(failWith!);
    final groups = page == 1 ? this.groups : older[page] ?? const [];
    return Success(
        NotificationPage(groups, hasMore: older.containsKey(page + 1)));
  }

  @override
  Future<Result<void>> markRead(String id) async {
    readIds.add(id);
    return failWith != null ? Failed(failWith!) : const Success(null);
  }

  @override
  Future<Result<void>> markAllRead(List<String> ids) async {
    bulk.add(ids);
    return failWith != null ? Failed(failWith!) : const Success(null);
  }
}

void main() {
  group('older pages', () {
    final today = DateTime(2026, 10, 15);
    final yesterday = DateTime(2026, 10, 14);

    test('"load more" adds the next page under the rows shown', () async {
      final repository = _FakeRepository([
        NotificationDateGroup(label: '', day: today, items: [_entry('a')]),
      ])
        ..older[2] = [
          NotificationDateGroup(
              label: '', day: yesterday, items: [_entry('b')]),
        ];
      final cubit = NotificationsCubit(repository);

      await cubit.load();
      expect(cubit.state.hasMore, isTrue);
      await cubit.loadMore();

      expect(repository.pagesAsked, [1, 2]);
      expect(cubit.state.groups.map((g) => g.items.single.id), ['a', 'b']);
      expect(cubit.state.hasMore, isFalse);
      expect(cubit.state.loadingMore, isFalse);
    });

    test('nothing more is asked for after the last page', () async {
      final repository = _FakeRepository([
        NotificationDateGroup(label: '', day: today, items: [_entry('a')]),
      ]);
      final cubit = NotificationsCubit(repository);

      await cubit.load();
      await cubit.loadMore();

      expect(repository.pagesAsked, [1]);
    });

    test('a refresh starts from the newest page again', () async {
      final repository = _FakeRepository([
        NotificationDateGroup(label: '', day: today, items: [_entry('a')]),
      ])
        ..older[2] = [
          NotificationDateGroup(
              label: '', day: yesterday, items: [_entry('b')]),
        ];
      final cubit = NotificationsCubit(repository);
      await cubit.load();
      await cubit.loadMore();

      await cubit.load();

      expect(cubit.state.groups.map((g) => g.items.single.id), ['a']);
      expect(cubit.state.hasMore, isTrue);
    });
  });

  test('a row marked read keeps its day header', () async {
    final day = DateTime(2026, 10, 15);
    final cubit = NotificationsCubit(_FakeRepository([
      NotificationDateGroup(label: '', day: day, items: [_entry('a')]),
    ]));
    await cubit.load();

    await cubit.markRead('a');

    expect(cubit.state.groups.single.day, day);
  });

  test('an empty feed is the "empty" status', () async {
    final cubit = NotificationsCubit(_FakeRepository([]));
    await cubit.load();
    expect(cubit.state.status, NotificationsStatus.empty);
  });

  test('a feed with items is "loaded" and counts the unread', () async {
    final cubit = NotificationsCubit(_FakeRepository([
      NotificationDateGroup(label: 'today', items: [
        _entry('a'),
        _entry('b', unread: false),
      ]),
    ]));
    await cubit.load();
    expect(cubit.state.status, NotificationsStatus.loaded);
    expect(cubit.state.unreadCount, 1);
  });

  test('marking read is optimistic and counted down', () async {
    final repository = _FakeRepository([
      NotificationDateGroup(label: 'today', items: [_entry('a')]),
    ]);
    final cubit = NotificationsCubit(repository);
    await cubit.load();

    await cubit.markRead('a');

    expect(repository.readIds, ['a']);
    expect(cubit.state.unreadCount, 0);
  });

  test('marking all read sends every unread id and leaves none unread',
      () async {
    final repository = _FakeRepository([
      NotificationDateGroup(label: 'today', items: [
        _entry('a'),
        _entry('b'),
        _entry('c', unread: false),
      ]),
    ]);
    final cubit = NotificationsCubit(repository);
    await cubit.load();

    await cubit.markAllRead();

    expect(repository.bulk.single, ['a', 'b']);
    expect(cubit.state.unreadCount, 0);
  });

  test('marking all read with nothing unread sends nothing', () async {
    final repository = _FakeRepository([
      NotificationDateGroup(
          label: 'today', items: [_entry('a', unread: false)]),
    ]);
    final cubit = NotificationsCubit(repository);
    await cubit.load();

    await cubit.markAllRead();

    expect(repository.bulk, isEmpty);
  });

  test('a failed load is the "error" status with the failure kept', () async {
    final cubit = NotificationsCubit(_FakeRepository([])
      ..failWith = const UnexpectedFailure(debugMessage: 'boom'));
    await cubit.load();
    expect(cubit.state.status, NotificationsStatus.error);
    expect(cubit.state.failure, isA<UnexpectedFailure>());
  });

  test('reset drops what is on screen', () async {
    final cubit = NotificationsCubit(_FakeRepository([
      NotificationDateGroup(label: 'today', items: [_entry('a')]),
    ]));
    await cubit.load();
    cubit.reset();
    expect(cubit.state.status, NotificationsStatus.initial);
    expect(cubit.state.groups, isEmpty);
  });
}
