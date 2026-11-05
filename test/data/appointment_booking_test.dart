import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/data/datasources/appointment_remote_data_source.dart';
import 'package:healthylife_ai/data/repositories/appointment_repository_impl.dart';
import 'package:healthylife_ai/domain/appointment_reminder_rules.dart';
import 'package:healthylife_ai/domain/entities/appointment_entities.dart';
import 'package:healthylife_ai/domain/repositories/appointment_reminder_scheduler.dart';

import '../helpers/scripted_api.dart';

class _Reminders implements AppointmentReminderScheduler {
  int replacements = 0;

  @override
  Future<void> replaceAll(List<PlannedReminder> reminders) async =>
      replacements++;

  @override
  Future<void> cancelAll() async {}
}

/// An appointment as the server answers (12.4).
Map<String, dynamic> _appointment(int id,
        {String startsAt = '2026-10-09T10:00:00+03:00',
        String status = 'booked'}) =>
    {
      'id': id,
      'type': 'follow_up',
      'channel': 'whatsapp',
      'starts_at': startsAt,
      'ends_at': '2026-10-09T10:30:00+03:00',
      'status': status,
      'topics': ['weight'],
    };

const _slots = {
  'type': 'follow_up',
  'duration_minutes': 30,
  'timezone': 'Asia/Gaza',
  'video_available': false,
  'days': [
    {
      'date': '2026-10-09',
      'times': ['2026-10-09T10:00:00+03:00', '2026-10-09T10:15:00+03:00'],
    },
    {'date': '2026-10-10', 'times': <String>[]},
  ],
};

void main() {
  late ScriptedApi api;
  late _Reminders reminders;
  late AppointmentRepositoryImpl repository;

  setUp(() {
    api = ScriptedApi({
      'GET me/appointments/slots': _slots,
      'GET me/appointments': <Object>[],
    });
    reminders = _Reminders();
    repository = AppointmentRepositoryImpl(
      MemoryStorageService(),
      AppointmentRemoteDataSource(api),
      reminders: reminders,
      clock: () => DateTime.utc(2026, 10, 7),
    );
  });

  AppointmentSlot firstSlot(AppointmentSlots slots) =>
      slots.days.first.times.first;

  test('the free times keep each start exactly as the server sent it (12.1)',
      () async {
    final slots =
        (await repository.getSlots(AppointmentType.followUp)).valueOrNull!;

    expect(api.to('GET', 'me/appointments/slots').single.query,
        {'type': 'follow_up'});
    expect(slots.durationMinutes, 30);
    expect(slots.videoAvailable, isFalse);
    expect(slots.days, hasLength(1), reason: 'a day without times is left out');
    expect(firstSlot(slots).value, '2026-10-09T10:00:00+03:00');
    expect(firstSlot(slots).startsAt,
        DateTime.utc(2026, 10, 9, 7).toLocal());
  });

  test('booking sends the guide\'s body and plans the reminders (12.2)',
      () async {
    api.routes['POST me/appointments'] = _appointment(7);
    final slots =
        (await repository.getSlots(AppointmentType.followUp)).valueOrNull!;

    final result = await repository.book(AppointmentRequest(
      type: AppointmentType.followUp,
      slot: firstSlot(slots),
      channel: AppointmentChannel.whatsapp,
      topics: ['weight', 'meals'],
      note: '  ',
    ));

    expect(result.valueOrNull?.id, 7);
    expect(api.to('POST', 'me/appointments').single.body, {
      'type': 'follow_up',
      'starts_at': '2026-10-09T10:00:00+03:00',
      'channel': 'whatsapp',
      'topics': ['weight', 'meals'],
    });
    expect(api.to('GET', 'me/appointments'), hasLength(1),
        reason: 'the upcoming list is read again');
    expect(reminders.replacements, 1);
  });

  test('a refusal keeps its code, and nothing is read again', () async {
    api.routes['POST me/appointments'] = const ApiException('taken',
        statusCode: 409, code: 'slot_taken');
    final slots =
        (await repository.getSlots(AppointmentType.followUp)).valueOrNull!;

    final result = await repository.book(AppointmentRequest(
      type: AppointmentType.followUp,
      slot: firstSlot(slots),
      channel: AppointmentChannel.phone,
    ));

    expect((result.failureOrNull as ApiFailure?)?.code, 'slot_taken');
    expect(api.to('GET', 'me/appointments'), isEmpty);
  });

  test('moving sends only the new start (12.3)', () async {
    api.routes['PATCH me/appointments/7'] =
        _appointment(7, startsAt: '2026-10-09T10:15:00+03:00');
    final slots =
        (await repository.getSlots(AppointmentType.followUp)).valueOrNull!;
    final booked = (await repository.getSlots(AppointmentType.followUp))
        .valueOrNull!
        .days
        .first
        .times
        .last;

    final result = await repository.reschedule(
      Appointment(
        id: 7,
        type: AppointmentType.followUp,
        channel: AppointmentChannel.whatsapp,
        startsAt: firstSlot(slots).startsAt,
        endsAt: null,
        status: AppointmentStatus.booked,
      ),
      booked,
    );

    expect(result.isSuccess, isTrue);
    expect(api.to('PATCH', 'me/appointments/7').single.body,
        {'starts_at': '2026-10-09T10:15:00+03:00'});
  });

  test('cancelling answers with the cancelled appointment (12.3)', () async {
    api.routes['DELETE me/appointments/7'] =
        _appointment(7, status: 'cancelled');

    final result = await repository.cancel(Appointment(
      id: 7,
      type: AppointmentType.followUp,
      channel: AppointmentChannel.whatsapp,
      startsAt: DateTime(2026, 10, 9, 10),
      endsAt: null,
      status: AppointmentStatus.booked,
    ));

    expect(result.valueOrNull?.status, AppointmentStatus.cancelled);
    expect(reminders.replacements, 1);
  });

  test('an appointment is open only while booked and ahead', () {
    final now = DateTime(2026, 10, 7);
    Appointment at(DateTime start, AppointmentStatus status) => Appointment(
          id: 1,
          type: AppointmentType.followUp,
          channel: AppointmentChannel.phone,
          startsAt: start,
          endsAt: null,
          status: status,
        );

    expect(at(DateTime(2026, 10, 8), AppointmentStatus.booked).isOpenAt(now),
        isTrue);
    expect(at(DateTime(2026, 10, 6), AppointmentStatus.booked).isOpenAt(now),
        isFalse);
    expect(
        at(DateTime(2026, 10, 8), AppointmentStatus.cancelled).isOpenAt(now),
        isFalse);
  });
}
