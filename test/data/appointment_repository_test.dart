import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/data/datasources/appointment_remote_data_source.dart';
import 'package:healthylife_ai/data/repositories/appointment_repository_impl.dart';
import 'package:healthylife_ai/domain/appointment_reminder_rules.dart';
import 'package:healthylife_ai/domain/entities/appointment_entities.dart';
import 'package:healthylife_ai/domain/repositories/appointment_reminder_scheduler.dart';

/// Records each replacement of the reminders and each clear at sign-out. When
/// [fails] is set, both throw, as a broken notification plugin would.
class _RecordingScheduler implements AppointmentReminderScheduler {
  final List<List<PlannedReminder>> replacements = [];
  int cancellations = 0;
  bool fails = false;

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async {
    if (fails) throw StateError('the scheduler is down');
    replacements.add(reminders);
  }

  @override
  Future<void> cancelAll() async {
    if (fails) throw StateError('the scheduler is down');
    cancellations++;
  }
}

/// Records each GET with its query. A GET answers with [answer]; an
/// [AppException] answer is thrown.
class _AppointmentApi implements ApiClient {
  final List<String> paths = [];
  final List<Map<String, dynamic>?> queries = [];
  Object? answer;

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    paths.add(path);
    queries.add(query);
    final next = answer;
    if (next is AppException) throw next;
    return next;
  }

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

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

Map<String, dynamic> _item(int id, String startsAt) => {
      'id': id,
      'type': 'follow_up',
      'channel': 'whatsapp',
      'starts_at': startsAt,
      'ends_at': null,
      'status': 'booked',
      'topics': <Object?>[],
      'note': null,
      'cancelled_by': null,
      'cancel_reason': null,
      'meeting_link': null,
    };

const NetworkException _offline =
    NetworkException('no connection', kind: NetworkFailureKind.offline);

/// Holds each GET until the test completes it, so overlapping reads finish in
/// the order the test chooses. [complete] takes the call's index, in call order.
class _GatedApi implements ApiClient {
  final List<Completer<Object?>> _calls = [];

  void complete(int index, Object? answer) => _calls[index].complete(answer);

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) {
    final call = Completer<Object?>();
    _calls.add(call);
    return call.future;
  }

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

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

/// Lets every write that is waiting run.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _AppointmentApi api;
  late MemoryStorageService storage;
  late AppointmentRepositoryImpl repository;

  setUp(() {
    api = _AppointmentApi();
    storage = MemoryStorageService();
    repository = AppointmentRepositoryImpl(
      storage,
      AppointmentRemoteDataSource(api),
    );
  });

  test('the scope is sent as the guide names it, on me/appointments', () async {
    api.answer = <Object>[];

    await repository.getAppointments(scope: AppointmentScope.past);

    expect(api.paths, ['me/appointments']);
    expect(api.queries.single, {'scope': 'past'});
  });

  test(
      'upcoming comes soonest first and past newest first, whatever the order sent',
      () async {
    api.answer = [
      _item(2, '2026-10-12T10:00:00+03:00'),
      _item(1, '2026-10-09T10:00:00+03:00'),
    ];

    final upcoming =
        await repository.getAppointments(scope: AppointmentScope.upcoming);
    final past = await repository.getAppointments(scope: AppointmentScope.past);

    expect(upcoming.valueOrNull!.map((a) => a.id), [1, 2]);
    expect(past.valueOrNull!.map((a) => a.id), [2, 1]);
  });

  test('an item the screen cannot show is left out, the rest are kept',
      () async {
    api.answer = [
      _item(1, '2026-10-09T10:00:00+03:00'),
      {'id': 2},
    ];

    final result =
        await repository.getAppointments(scope: AppointmentScope.upcoming);

    expect(result.valueOrNull!.map((a) => a.id), [1]);
  });

  test('an answer that is not a list is an unexpected answer', () async {
    api.answer = {'items': <Object>[]};

    final result =
        await repository.getAppointments(scope: AppointmentScope.upcoming);

    expect(result.failureOrNull, isA<UnexpectedFailure>());
  });

  test('offline, the last list of the same scope is shown', () async {
    api.answer = [_item(1, '2026-10-09T10:00:00+03:00')];
    await repository.getAppointments(scope: AppointmentScope.upcoming);

    api.answer = _offline;
    final result =
        await repository.getAppointments(scope: AppointmentScope.upcoming);

    expect(result.valueOrNull!.map((a) => a.id), [1]);
  });

  test('offline, the list of the other scope is not shown', () async {
    api.answer = [_item(1, '2026-10-09T10:00:00+03:00')];
    await repository.getAppointments(scope: AppointmentScope.upcoming);

    api.answer = _offline;
    final result =
        await repository.getAppointments(scope: AppointmentScope.past);

    expect(result.failureOrNull, isA<NetworkFailure>());
  });

  test('offline with nothing kept is a network failure', () async {
    api.answer = _offline;

    final result =
        await repository.getAppointments(scope: AppointmentScope.upcoming);

    expect(result.failureOrNull, isA<NetworkFailure>());
  });

  test('signing out forgets the copies of both lists', () async {
    api.answer = [_item(1, '2026-10-09T10:00:00+03:00')];
    await repository.getAppointments(scope: AppointmentScope.upcoming);
    await repository.getAppointments(scope: AppointmentScope.past);

    await repository.forgetPatientData();
    api.answer = _offline;
    final upcoming =
        await repository.getAppointments(scope: AppointmentScope.upcoming);
    final past = await repository.getAppointments(scope: AppointmentScope.past);

    expect(upcoming.failureOrNull, isA<NetworkFailure>());
    expect(past.failureOrNull, isA<NetworkFailure>());
  });

  group('appointment reminders (API guide 10.6)', () {
    // The clock is 06:00 UTC on 14 October. The visit is at 10:00 in Hebron on
    // 15 October, which is 07:00 UTC.
    final clock = DateTime.utc(2026, 10, 14, 6);

    late _RecordingScheduler scheduler;
    late AppointmentRepositoryImpl planning;

    setUp(() {
      scheduler = _RecordingScheduler();
      planning = AppointmentRepositoryImpl(
        MemoryStorageService(),
        AppointmentRemoteDataSource(api),
        reminders: scheduler,
        clock: () => clock,
      );
    });

    test('a fresh upcoming list plans the three reminders, in time order',
        () async {
      api.answer = [_item(7, '2026-10-15T10:00:00+03:00')];

      await planning.getAppointments(scope: AppointmentScope.upcoming);

      final planned = scheduler.replacements.single;
      expect(planned.map((r) => r.lead), [
        ReminderLead.oneDay,
        ReminderLead.oneHour,
        ReminderLead.fiveMinutes,
      ]);
      expect(planned.map((r) => r.at.toUtc()), [
        DateTime.utc(2026, 10, 14, 7),
        DateTime.utc(2026, 10, 15, 6),
        DateTime.utc(2026, 10, 15, 6, 55),
      ]);
    });

    test('an appointment an hour away keeps only its five-minute reminder',
        () async {
      api.answer = [_item(8, '2026-10-14T10:00:00+03:00')];

      await planning.getAppointments(scope: AppointmentScope.upcoming);

      expect(scheduler.replacements.single.map((r) => r.lead),
          [ReminderLead.fiveMinutes]);
    });

    test('the past list does not touch the reminders', () async {
      api.answer = [_item(7, '2026-10-15T10:00:00+03:00')];

      await planning.getAppointments(scope: AppointmentScope.past);

      expect(scheduler.replacements, isEmpty);
    });

    test('an offline read keeps the reminders already planned', () async {
      api.answer = [_item(7, '2026-10-15T10:00:00+03:00')];
      await planning.getAppointments(scope: AppointmentScope.upcoming);

      api.answer = _offline;
      final result =
          await planning.getAppointments(scope: AppointmentScope.upcoming);

      expect(result.valueOrNull!.single.id, 7);
      expect(scheduler.replacements, hasLength(1));
    });

    test('a scheduler that fails does not fail the read', () async {
      scheduler.fails = true;
      api.answer = [_item(7, '2026-10-15T10:00:00+03:00')];

      final result =
          await planning.getAppointments(scope: AppointmentScope.upcoming);

      expect(result.valueOrNull!.single.id, 7);
    });

    test('refreshReminders reads the upcoming list and plans from it',
        () async {
      api.answer = [_item(7, '2026-10-15T10:00:00+03:00')];

      await planning.refreshReminders();

      expect(api.queries.last, {'scope': 'upcoming'});
      expect(scheduler.replacements.single, hasLength(3));
    });

    test(
        'an older read that answers last cannot replace a newer read\'s reminders',
        () async {
      final gate = _GatedApi();
      final gated = AppointmentRepositoryImpl(
        MemoryStorageService(),
        AppointmentRemoteDataSource(gate),
        reminders: scheduler,
        clock: () => clock,
      );

      final older = gated.getAppointments(scope: AppointmentScope.upcoming);
      final newer = gated.getAppointments(scope: AppointmentScope.upcoming);
      await _settle();

      // The newer read finds the visit cancelled; the older one still has it.
      gate.complete(1, <Object?>[]);
      await newer;
      gate.complete(0, [_item(7, '2026-10-15T10:00:00+03:00')]);
      await older;

      expect(scheduler.replacements, hasLength(1));
      expect(scheduler.replacements.single, isEmpty);
    });

    test('a read still in flight at sign-out cannot plan reminders afterwards',
        () async {
      final gate = _GatedApi();
      final gated = AppointmentRepositoryImpl(
        MemoryStorageService(),
        AppointmentRemoteDataSource(gate),
        reminders: scheduler,
        clock: () => clock,
      );

      final inFlight = gated.getAppointments(scope: AppointmentScope.upcoming);
      await _settle();
      await gated.forgetPatientData();
      gate.complete(0, [_item(7, '2026-10-15T10:00:00+03:00')]);
      await inFlight;

      expect(scheduler.replacements, isEmpty);
      expect(scheduler.cancellations, 1);
    });

    test('signing out cancels the reminders', () async {
      await planning.forgetPatientData();

      expect(scheduler.cancellations, 1);
    });

    test('a scheduler that cannot cancel does not stop sign-out', () async {
      scheduler.fails = true;

      await expectLater(planning.forgetPatientData(), completes);
    });
  });
}
