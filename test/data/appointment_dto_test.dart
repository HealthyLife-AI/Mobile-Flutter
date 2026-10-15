import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/models/appointment_dto.dart';
import 'package:healthylife_ai/domain/entities/appointment_entities.dart';

/// One item as `GET /me/appointments` sends it (API guide 12.4).
Map<String, dynamic> _item({
  Object? id = 7,
  Object? startsAt = '2026-10-09T10:00:00+03:00',
  Object? endsAt = '2026-10-09T10:30:00+03:00',
  Object? type = 'follow_up',
  Object? channel = 'video',
  Object? status = 'booked',
  Object? topics = const ['weight'],
  Object? note,
  Object? cancelledBy,
  Object? cancelReason,
  Object? meetingLink,
}) =>
    {
      'id': id,
      'type': type,
      'channel': channel,
      'starts_at': startsAt,
      'ends_at': endsAt,
      'status': status,
      'topics': topics,
      'note': note,
      'cancelled_by': cancelledBy,
      'cancel_reason': cancelReason,
      'meeting_link': meetingLink,
    };

void main() {
  test('the times are the instants the server sent, in the device time', () {
    final appointment = AppointmentDto.fromJson(_item())!;

    // 10:00 at +03:00 is 07:00 UTC.
    expect(appointment.startsAt.isAtSameMomentAs(DateTime.utc(2026, 10, 9, 7)),
        isTrue);
    expect(appointment.startsAt.isUtc, isFalse);
    expect(
        appointment.endsAt!.isAtSameMomentAs(DateTime.utc(2026, 10, 9, 7, 30)),
        isTrue);
  });

  test('the fields are read under the names the guide uses', () {
    final appointment = AppointmentDto.fromJson(_item(
      type: 'results_review',
      channel: 'video',
      status: 'booked',
      topics: ['weight', 'meals'],
      note: 'Bring the scale readings',
      meetingLink: 'https://meet.google.com/abc',
    ))!;

    expect(appointment.id, 7);
    expect(appointment.type, AppointmentType.resultsReview);
    expect(appointment.channel, AppointmentChannel.video);
    expect(appointment.status, AppointmentStatus.booked);
    expect(appointment.topics, ['weight', 'meals']);
    expect(appointment.note, 'Bring the scale readings');
    expect(appointment.meetingLink, 'https://meet.google.com/abc');
  });

  test(
      'an item without a usable id or start is skipped, since it cannot be shown',
      () {
    expect(AppointmentDto.fromJson(_item(id: null)), isNull);
    expect(AppointmentDto.fromJson(_item(id: '7')), isNull);
    expect(AppointmentDto.fromJson(_item(startsAt: null)), isNull);
    expect(AppointmentDto.fromJson(_item(startsAt: 'not a date')), isNull);
  });

  test('a missing end is left out, not treated as an error', () {
    final appointment = AppointmentDto.fromJson(_item(endsAt: null))!;

    expect(appointment.endsAt, isNull);
  });

  test('values this version does not know are kept as unknown', () {
    final appointment = AppointmentDto.fromJson(_item(
      type: 'group_session',
      channel: 'carrier-pigeon',
      status: 'rescheduled',
      cancelledBy: 'robot',
    ))!;

    expect(appointment.type, AppointmentType.unknown);
    expect(appointment.channel, AppointmentChannel.unknown);
    expect(appointment.status, AppointmentStatus.unknown);
    expect(appointment.cancelledBy, CancelledBy.unknown);
  });

  test('the cancellation fields are set only when the server sends them', () {
    final booked = AppointmentDto.fromJson(_item())!;
    final cancelled = AppointmentDto.fromJson(_item(
      status: 'cancelled',
      cancelledBy: 'system',
      cancelReason: 'follow_up_ended',
    ))!;

    expect(booked.cancelledBy, isNull);
    expect(cancelled.status, AppointmentStatus.cancelled);
    expect(cancelled.cancelledBy, CancelledBy.system);
    expect(cancelled.cancelReason, 'follow_up_ended');
  });

  test('blank text and topics that are not text are left out', () {
    final appointment = AppointmentDto.fromJson(_item(
      topics: ['  weight ', '', 3, null, 'meals'],
      note: '   ',
      meetingLink: '',
    ))!;

    expect(appointment.topics, ['weight', 'meals']);
    expect(appointment.note, isNull);
    expect(appointment.meetingLink, isNull);
  });
}
