import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/presentation/screens/book_appointment_screen.dart';
import 'package:healthylife_ai/presentation/screens/schedule_calls_screen.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';
import '../../helpers/scripted_api.dart';

/// A free day two days ahead, with two times.
Map<String, dynamic> _slots() {
  final day = DateTime.now().add(const Duration(days: 2));
  final date = '${day.year}-${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
  return {
    'type': 'follow_up',
    'duration_minutes': 30,
    'video_available': false,
    'days': [
      {
        'date': date,
        'times': ['${date}T10:00:00+03:00', '${date}T10:30:00+03:00'],
      },
    ],
  };
}

Map<String, dynamic> _booked(int id) {
  final start = DateTime.now().toUtc().add(const Duration(days: 3));
  return {
    'id': id,
    'type': 'follow_up',
    'channel': 'whatsapp',
    'starts_at': start.toIso8601String(),
    'ends_at': start.add(const Duration(minutes: 30)).toIso8601String(),
    'status': 'booked',
  };
}

void main() {
  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  Future<void> open(WidgetTester tester, ScriptedApi api) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 2600);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(appProviders(
      const ScheduleCallsScreen(),
      dependencies: AppDependencies.inMemory(api: api),
      theme: AppTheme.light,
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  testWidgets('with nothing upcoming, a time is booked (12.1, 12.2)',
      (tester) async {
    final api = ScriptedApi({
      'GET me/appointments': <Object>[],
      'GET me/appointments/slots': _slots(),
      'POST me/appointments': _booked(7),
    });
    await open(tester, api);

    await tester.tap(find.text('حجز موعد جديد'));
    await settle(tester);
    expect(find.byType(BookAppointmentScreen), findsOneWidget);

    // The day chip, then the two time chips.
    await tester.tap(find.byType(ChoiceChip).at(1));
    await tester.pump();
    await tester.tap(find.text('تأكيد الحجز'));
    await settle(tester);

    final body = api.to('POST', 'me/appointments').single.body! as Map;
    expect(body['type'], 'follow_up');
    expect(body['starts_at'], endsWith('T10:00:00+03:00'));
    expect(body['channel'], 'whatsapp');
    expect(find.byType(BookAppointmentScreen), findsNothing);
    expect(find.text('تم حجز موعدك'), findsOneWidget);
  });

  testWidgets('a time just taken reads the free times again', (tester) async {
    final api = ScriptedApi({
      'GET me/appointments': <Object>[],
      'GET me/appointments/slots': _slots(),
      'POST me/appointments': const ApiException('taken',
          statusCode: 409, code: 'slot_taken'),
    });
    await open(tester, api);
    await tester.tap(find.text('حجز موعد جديد'));
    await settle(tester);

    await tester.tap(find.byType(ChoiceChip).at(1));
    await tester.pump();
    await tester.tap(find.text('تأكيد الحجز'));
    await settle(tester);

    expect(find.text('هذا الوقت لم يعد متاحًا، اختر وقتًا آخر.'),
        findsOneWidget);
    expect(api.to('GET', 'me/appointments/slots'), hasLength(2));
    expect(find.byType(BookAppointmentScreen), findsOneWidget);
  });

  testWidgets('the next appointment can be cancelled (12.3)', (tester) async {
    final api = ScriptedApi({
      'GET me/appointments': [_booked(7)],
      'DELETE me/appointments/7': {..._booked(7), 'status': 'cancelled'},
    });
    await open(tester, api);

    expect(find.text('حجز موعد جديد'), findsNothing,
        reason: 'one upcoming appointment at a time');
    expect(find.text('تغيير الموعد'), findsOneWidget);

    await tester.tap(find.text('إلغاء الموعد'));
    await settle(tester);
    await tester.tap(find.text('إلغاء الموعد').last);
    await settle(tester);

    expect(api.to('DELETE', 'me/appointments/7'), hasLength(1));
  });

  testWidgets('a locked appointment offers the nutritionist\'s WhatsApp',
      (tester) async {
    final api = ScriptedApi({
      'GET me/appointments': [_booked(7)],
      'DELETE me/appointments/7': const ApiException('locked',
          statusCode: 422,
          code: 'appointment_locked',
          body: {'lock_hours': 12, 'nutritionist_whatsapp': '+970599123456'}),
    });
    await open(tester, api);

    await tester.tap(find.text('إلغاء الموعد'));
    await settle(tester);
    await tester.tap(find.text('إلغاء الموعد').last);
    await settle(tester);

    expect(find.textContaining('قبل أقل من'), findsOneWidget);
    expect(find.text('فتح واتساب'), findsOneWidget);
  });
}
