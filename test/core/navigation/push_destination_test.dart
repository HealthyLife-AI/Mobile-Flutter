import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/navigation/push_destination.dart';

void main() {
  group('destinationForType (API guide 10.3)', () {
    test('plan types open my plan', () {
      expect(destinationForType('plan_activated'), PushDestination.myPlan);
      expect(destinationForType('plan_updated'), PushDestination.myPlan);
    });

    test('proposal decisions open the health profile', () {
      expect(destinationForType('proposal_decided'),
          PushDestination.healthProfile);
    });

    test('appointment changes open appointments', () {
      expect(destinationForType('appointment_cancelled'),
          PushDestination.appointments);
      expect(destinationForType('appointment_rescheduled'),
          PushDestination.appointments);
    });

    test('follow-up resumed opens home and the log reminder opens log a meal',
        () {
      expect(destinationForType('follow_up_resumed'), PushDestination.home);
      expect(destinationForType('log_reminder'), PushDestination.logMeal);
    });

    test('review types open the notes screen', () {
      expect(destinationForType('review_new'), PushDestination.notes);
      expect(destinationForType('review_updated'), PushDestination.notes);
    });

    test('unknown, empty and missing types open the inbox', () {
      expect(destinationForType('something_new'), PushDestination.inbox);
      expect(destinationForType(''), PushDestination.inbox);
      expect(destinationForType(null), PushDestination.inbox);
    });
  });

  group('PushTap.fromData', () {
    test('reads the id and the type', () {
      final tap = PushTap.fromData({
        'notification_id': '42',
        'type': 'plan_updated',
        'plan_id': '7',
      });

      expect(tap?.notificationId, '42');
      expect(tap?.type, 'plan_updated');
    });

    test('no data, or neither an id nor a type, gives no tap', () {
      expect(PushTap.fromData(null), isNull);
      expect(PushTap.fromData({'category': 'meals'}), isNull);
    });

    test('a type alone is enough to open a screen', () {
      final tap = PushTap.fromData({'type': 'log_reminder'});

      expect(tap?.notificationId, isNull);
      expect(tap?.type, 'log_reminder');
    });

    test('non-string values and blank strings are ignored', () {
      expect(PushTap.fromData({'notification_id': 42, 'type': '   '}), isNull);
    });

    test('surrounding spaces are trimmed', () {
      expect(
        PushTap.fromData({'notification_id': ' 42 '})?.notificationId,
        '42',
      );
    });

    test('a review push carries the id of the note it names', () {
      final tap = PushTap.fromData({
        'notification_id': '42',
        'type': 'review_new',
        'review_id': ' 12 ',
      });

      expect(tap?.reviewId, '12');
      expect(
        PushTap.fromData({'type': 'review_updated', 'review_id': 12})?.reviewId,
        isNull,
      );
    });
  });

  group('isAppointmentChangePush (API guide 10.6)', () {
    test('only the two appointment types count', () {
      expect(
          isAppointmentChangePush({'type': 'appointment_cancelled'}), isTrue);
      expect(
          isAppointmentChangePush({'type': 'appointment_rescheduled'}), isTrue);
      expect(isAppointmentChangePush({'type': 'log_reminder'}), isFalse);
      expect(isAppointmentChangePush({'notification_id': '42'}), isFalse);
      expect(isAppointmentChangePush(null), isFalse);
    });
  });
}
