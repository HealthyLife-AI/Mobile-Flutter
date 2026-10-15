import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/presentation/bloc/measurements/measurements_cubit.dart';
import 'package:healthylife_ai/presentation/screens/progress_screen.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';

/// The server, scripted by path. Writes are recorded.
class _Server implements ApiClient {
  _Server(this.answers);

  final Map<String, Object?> answers;
  final List<String> writes = [];

  @override
  Future<dynamic> get(String path,
          {Map<String, dynamic>? query, bool auth = true}) async =>
      answers[path];

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    writes.add('POST $path');
    return null;
  }

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) async {
    writes.add('DELETE $path');
    return null;
  }

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);
}

Map<String, Object?> _answers({
  List<Object> reviews = const [],
  String? whatsapp,
  List<Object> appointments = const [],
}) =>
    {
      'me/progress': {
        'weight_trend': <Object>[],
        'adherence': {'adherence_percent': 80},
      },
      'me/nutritionist': {
        'name': 'د. سامر',
        'gender': 'male',
        'whatsapp_number': whatsapp,
      },
      'me/reviews': reviews,
      'me/appointments': appointments,
      'me/measurements': [
        {
          'id': 1,
          'recorded_at': '2026-10-01',
          'source': 'self-reported',
          'weight_kg': 82,
          'waist_cm': 90,
        },
        {
          'id': 2,
          'recorded_at': '2026-10-08',
          'source': 'self-reported',
          'weight_kg': 81,
          'waist_cm': 88,
        },
      ],
    };

Map<String, Object?> _review({bool acknowledged = false}) => {
      'id': 12,
      'rating': 'on_track',
      'note': 'التزام رائع بوجبة الفطور هذا الأسبوع.',
      'key_points': ['قلّل الخبز الأبيض في العشاء'],
      'tasks': [
        {'id': 40, 'title': 'اشرب 8 أكواب ماء يومياً', 'done_at': null},
      ],
      'acknowledged_at': acknowledged ? '2026-10-07T10:00:00+00:00' : null,
      'edited_at': null,
      'created_at': '2026-10-06T12:00:00+00:00',
    };

void main() {
  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  Future<_Server> open(WidgetTester tester, Map<String, Object?> answers,
      {double width = 420}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 4000);
    addTearDown(tester.view.reset);
    final server = _Server(answers);
    final deps = AppDependencies.inMemory(api: server);
    await tester.pumpWidget(appProviders(
      const ProgressScreen(),
      dependencies: deps,
      // The app's theme, so text that inherits its family measures in the
      // loaded font.
      theme: AppTheme.light,
    ));
    await tester
        .element(find.byType(ProgressScreen))
        .read<MeasurementsCubit>()
        .load();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    return server;
  }

  testWidgets('the latest note is the nutritionist\'s, not the design sample',
      (tester) async {
    await open(tester, _answers(reviews: [_review()]));

    expect(find.text('على المسار'), findsOneWidget);
    expect(find.text('التزام رائع بوجبة الفطور هذا الأسبوع.'), findsOneWidget);
    expect(find.textContaining('قلّل الخبز الأبيض'), findsOneWidget);
    expect(find.text('اشرب 8 أكواب ماء يومياً'), findsOneWidget);
    expect(find.text('مهمة واحدة'), findsOneWidget);
    // The design's sample content is gone.
    expect(find.text('4.5 / 5.0'), findsNothing);
    expect(find.textContaining('فخورة'), findsNothing);
    expect(find.text('0:48'), findsNothing);
    expect(find.text('متصل الآن'), findsNothing);
    // Waiting for «فهمت»: the notes tab says so.
    expect(find.text('جديد'), findsOneWidget);
  });

  testWidgets('a task tap and «فهمت» reach the server', (tester) async {
    final server = await open(tester, _answers(reviews: [_review()]));

    await tester.tap(find.text('اشرب 8 أكواب ماء يومياً'));
    await tester.pump();
    await tester.tap(find.text('فهمت'));
    await tester.pump();

    expect(server.writes,
        ['POST me/tasks/40/done', 'POST me/reviews/12/acknowledge']);
  });

  testWidgets('an acknowledged note shows as seen, without the "new" badge',
      (tester) async {
    await open(tester, _answers(reviews: [_review(acknowledged: true)]));

    expect(find.text('تم الاطلاع'), findsOneWidget);
    expect(find.text('فهمت'), findsNothing);
    expect(find.text('جديد'), findsNothing);
  });

  testWidgets('no note yet: an honest empty line, no tasks, no key points',
      (tester) async {
    await open(tester, _answers());

    expect(find.text('لا توجد ملاحظات بعد. ستظهر ملاحظات أخصائيك هنا.'),
        findsOneWidget);
    expect(find.text('أهم النقاط'), findsNothing);
    expect(find.text('توجيهات الأسبوع القادم'), findsNothing);
  });

  testWidgets('the circumferences are the patient\'s readings', (tester) async {
    await open(tester, _answers());

    // Waist 90 → 88 cm; the design's 78 cm and −4 cm are gone.
    expect(find.text('٨٨'), findsOneWidget);
    expect(find.text('−٢ سم'), findsOneWidget);
    expect(find.text('٧٨'), findsNothing);
    expect(find.text('-4 سم'), findsNothing);
  });

  testWidgets('WhatsApp and the next appointment show only when known',
      (tester) async {
    await open(tester, _answers());
    expect(find.text('مناقشة التقييم عبر الواتساب مباشرة'), findsNothing);
    expect(find.textContaining('موعدك القادم'), findsNothing);
    expect(find.textContaining('الأحد القادم'), findsNothing);
  });

  testWidgets('everything at once fits the narrowest phone', (tester) async {
    // An overflow fails the test on its own.
    await open(
      tester,
      _answers(
          reviews: [_review()],
          whatsapp: '+970599123456',
          appointments: [
            {
              'id': 3,
              'type': 'follow_up',
              'channel': 'whatsapp',
              'starts_at': '2026-11-02T10:00:00+02:00',
              'status': 'booked',
            },
          ]),
      width: 320,
    );
    expect(find.text('على المسار'), findsOneWidget);
  });

  testWidgets('with a number and a booking, both show', (tester) async {
    await open(
      tester,
      _answers(whatsapp: '+970599123456', appointments: [
        {
          'id': 3,
          'type': 'follow_up',
          'channel': 'whatsapp',
          'starts_at': '2026-11-02T10:00:00+02:00',
          'status': 'booked',
        },
      ]),
    );

    expect(find.text('مناقشة التقييم عبر الواتساب مباشرة'), findsOneWidget);
    expect(find.textContaining('موعدك القادم'), findsOneWidget);
  });
}
