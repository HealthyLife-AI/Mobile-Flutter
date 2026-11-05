import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/data/datasources/notification_data_source.dart';
import 'package:healthylife_ai/data/repositories/notification_repository_impl.dart';
import 'package:healthylife_ai/domain/entities/notification_entities.dart';

/// A feed the test controls, so the repository's own rules (dedupe, the
/// specialist name, the persisted read state) are what is under test.
class _FakeSource implements NotificationDataSource {
  _FakeSource(this.groups);

  List<NotificationDateGroup> groups;
  final List<String> readIds = [];
  int readAllCalls = 0;

  @override
  Future<NotificationPage> fetchPage(int page) async =>
      NotificationPage(groups);

  @override
  Future<void> markRead(String id) async => readIds.add(id);

  @override
  Future<void> markAllRead() async => readAllCalls++;
}

NotificationEntry _entry(String id,
        {bool unread = false,
        NotificationVariant variant = NotificationVariant.plain,
        String title = 't'}) =>
    NotificationEntry(
      id: id,
      category: NotificationCategory.other,
      variant: variant,
      title: title,
      body: 'b',
      time: 'now',
      emoji: '⭐',
      unread: unread,
    );

void main() {
  late MemoryStorageService storage;

  setUp(() => storage = MemoryStorageService());

  NotificationRepositoryImpl build(_FakeSource source,
          {Future<String?> Function()? specialist}) =>
      NotificationRepositoryImpl(storage, source, specialistName: specialist);

  test('the same id sent twice is shown once', () async {
    final source = _FakeSource([
      NotificationDateGroup(label: 'today', items: [
        _entry('a', unread: true),
        _entry('a', unread: true),
        _entry('b'),
      ]),
    ]);
    final groups = (await build(source).getPage(1)).valueOrNull!.groups;
    final ids = groups.expand((g) => g.items).map((e) => e.id).toList();
    expect(ids, ['a', 'b']);
  });

  test('a group left empty after dedupe is dropped', () async {
    final source = _FakeSource([
      NotificationDateGroup(label: 'today', items: [_entry('a')]),
      NotificationDateGroup(label: 'yesterday', items: [_entry('a')]),
    ]);
    final groups = (await build(source).getPage(1)).valueOrNull!.groups;
    expect(groups.map((g) => g.label), ['today']);
  });

  test('the specialist note names the real nutritionist', () async {
    final source = _FakeSource([
      NotificationDateGroup(label: 'today', items: [
        _entry('n',
            variant: NotificationVariant.specialistNote,
            title: 'ملاحظة جديدة من {specialist}'),
      ]),
    ]);
    final groups =
        (await build(source, specialist: () async => 'د. سارة').getPage(1))
            .valueOrNull!
            .groups;
    final note = groups.single.items.single;
    expect(note.title, 'ملاحظة جديدة من د. سارة');
    expect(note.specialistName, 'د. سارة');
  });

  test('with no profile, a neutral word stands in and no placeholder leaks',
      () async {
    final source = _FakeSource([
      NotificationDateGroup(label: 'today', items: [
        _entry('n',
            variant: NotificationVariant.specialistNote,
            title: 'ملاحظة جديدة من {specialist}'),
      ]),
    ]);
    final groups = (await build(source).getPage(1)).valueOrNull!.groups;
    final note = groups.single.items.single;
    expect(note.title.contains('{specialist}'), isFalse);
    expect(note.specialistName, isNull);
  });

  test('a marked notification stays read on the next load', () async {
    final source = _FakeSource([
      NotificationDateGroup(label: 'today', items: [_entry('a', unread: true)]),
    ]);
    final repository = build(source);

    await repository.getPage(1);
    await repository.markRead('a');
    final groups = (await repository.getPage(1)).valueOrNull!.groups;

    expect(groups.single.items.single.unread, isFalse);
  });

  test('marking all read persists every id', () async {
    final source = _FakeSource([
      NotificationDateGroup(label: 'today', items: [
        _entry('a', unread: true),
        _entry('b', unread: true),
      ]),
    ]);
    final repository = build(source);

    await repository.markAllRead(['a', 'b']);
    final groups = (await repository.getPage(1)).valueOrNull!.groups;

    expect(groups.single.items.every((e) => !e.unread), isTrue);
  });

  test('signing out forgets the read state', () async {
    final source = _FakeSource([
      NotificationDateGroup(label: 'today', items: [_entry('a', unread: true)]),
    ]);
    final repository = build(source);

    await repository.markRead('a');
    await repository.forgetPatientData();
    final groups = (await repository.getPage(1)).valueOrNull!.groups;

    expect(groups.single.items.single.unread, isTrue);
  });

  test('a mark is also sent to the server once', () async {
    final source = _FakeSource([
      NotificationDateGroup(label: 'today', items: [_entry('a', unread: true)]),
    ]);
    await build(source).markRead('a');
    expect(source.readIds, ['a']);
  });

  test('a server that is down still leaves the row read here', () async {
    final source = _ServerDownSource();
    final repository = build(source);

    final mark = await repository.markRead('a');
    final groups = (await repository.getPage(1)).valueOrNull!.groups;

    expect(mark.isSuccess, isTrue);
    expect(groups.single.items.single.unread, isFalse);
  });
}

/// A feed that answers, but whose write endpoint is failing.
class _ServerDownSource extends _FakeSource {
  _ServerDownSource()
      : super([
          NotificationDateGroup(
              label: 'today', items: [_entry('a', unread: true)]),
        ]);

  @override
  Future<void> markRead(String id) async =>
      throw const NetworkException('offline');
}
