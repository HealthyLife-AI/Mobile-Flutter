import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/data/meal_plan_repository.dart';
import 'package:healthylife_ai/core/theme/app_text_styles.dart';
import 'package:healthylife_ai/models/meal_plan_models.dart';
import 'package:healthylife_ai/screens/weekly_plan_screen.dart';
import 'package:healthylife_ai/widgets/patient_instructions_card.dart';

const _title = 'تعليمات أخصائيتك';
const _line1 = 'قلّل الصوديوم والأطعمة المصنّعة، وفضّل الأكل الطبيعي والطازج.';
const _line2 = 'قِس مستوى السكر قبل الوجبات وبعدها.';
const _line3 = 'حافظ على هدوئك وخصص وقتًا يوميًا لتمارين التنفس.';
const _multiLine = '$_line1\n$_line2\n$_line3';

Map<String, dynamic> _response(Object? instructions) => {'patient_instructions': instructions, 'meals': <Object>[]};

class _MemoryCache implements MealPlanCache {
  String? body;

  @override
  Future<String?> read() async => body;

  @override
  Future<void> write(String body) async => this.body = body;

  @override
  Future<void> clear() async => body = null;
}

/// Stands in for `GET /me/meal-plan`. Set [body] to an [Exception] to
/// simulate having no connection.
class _Server {
  _Server(this.body);

  Object body;

  Future<Map<String, dynamic>> fetch() async {
    final b = body;
    if (b is Exception) throw b;
    return b as Map<String, dynamic>;
  }
}

MealPlanRepository _repo(_Server server, [_MemoryCache? cache]) =>
    MealPlanRepository(fetch: server.fetch, cache: cache ?? _MemoryCache());

/// The plan's date chips are a fixed 72px wide, which the Ahem test font
/// (every glyph a full em) overflows. Same workaround as
/// screen_layout_test.dart: real Arabic metrics under the app's font name.
Future<void> _loadSegoeAsAppFont() async {
  final loader = FontLoader(AppTextStyles.fontFamily);
  for (final name in ['segoeui.ttf', 'segoeuib.ttf']) {
    final file = File('C:/Windows/Fonts/$name');
    if (file.existsSync()) {
      loader.addFont(file.readAsBytes().then((b) => b.buffer.asByteData(b.offsetInBytes, b.lengthInBytes)));
    }
  }
  await loader.load();
}

/// Runs animations for two seconds. pumpAndSettle never returns on this
/// screen: the CTA inside every MealCard shimmers on a loop.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _pumpPlan(WidgetTester tester, MealPlanRepository repo) async {
  // Tall enough that the whole plan, meals included, is built.
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(800, 3000);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
    home: WeeklyPlanScreen(repository: repo),
  ));
  await _settle(tester);
}

void main() {
  group('parsePatientInstructions', () {
    test('a multi-line response gives one bullet per line', () {
      expect(parsePatientInstructions(_multiLine), [_line1, _line2, _line3]);
    });

    test('null, empty and whitespace-only give no lines', () {
      for (final raw in <Object?>[null, '', '   ', ' \n\t\n  \r\n', 42]) {
        expect(parsePatientInstructions(raw), isEmpty, reason: 'input: ${jsonEncode(raw)}');
      }
    });

    test('trims lines, drops blank ones, accepts CRLF and strips typed list markers', () {
      expect(
        parsePatientInstructions('  - أولًا  \r\n\r\n• ثانيًا\n\n-5 كغ هو الهدف'),
        ['أولًا', 'ثانيًا', '-5 كغ هو الهدف'],
      );
    });

    test('a line of only invisible characters counts as empty', () {
      final rlm = String.fromCharCode(0x200F);
      final zwsp = String.fromCharCode(0x200B);
      expect(parsePatientInstructions('$rlm \n $zwsp$rlm\n'), isEmpty);
    });

    test('a response without the field has no instructions', () {
      expect(MealPlan.fromJson(const {'meals': <Object>[]}).patientInstructions, isEmpty);
    });

    test('MealPlan.toString never contains the text', () {
      final plan = MealPlan.fromJson(_response(_multiLine));
      expect(plan.toString(), isNot(contains('الصوديوم')));
      expect(plan.toString(), contains('3 lines'));
    });
  });

  group('MealPlanRepository', () {
    test('caches the response and serves it offline', () async {
      final cache = _MemoryCache();
      expect(await _repo(_Server(_response(_multiLine)), cache).refresh(), isTrue);

      final offline = _repo(_Server(Exception('offline')), cache);
      await offline.loadCached();
      expect(offline.plan!.patientInstructions, [_line1, _line2, _line3]);

      expect(await offline.refresh(), isFalse);
      expect(offline.plan!.patientInstructions, [_line1, _line2, _line3]);
    });

    test('an update to null clears the instructions in memory and in the cache', () async {
      final cache = _MemoryCache();
      final server = _Server(_response(_multiLine));
      final repo = _repo(server, cache);
      await repo.refresh();

      server.body = _response(null);
      await repo.refresh();
      expect(repo.plan!.patientInstructions, isEmpty);

      final afterRestart = _repo(_Server(Exception('offline')), cache);
      await afterRestart.loadCached();
      expect(afterRestart.plan!.patientInstructions, isEmpty);
    });

    test('when refreshes overlap, the one started last wins', () async {
      final older = Completer<Map<String, dynamic>>();
      final newer = Completer<Map<String, dynamic>>();
      final pending = [older, newer];
      final repo = MealPlanRepository(fetch: () => pending.removeAt(0).future, cache: _MemoryCache());

      final first = repo.refresh();
      final second = repo.refresh();
      newer.complete(_response('جديد'));
      await second;
      older.complete(_response('قديم'));
      await first;

      expect(repo.plan!.patientInstructions, ['جديد']);
    });

    test('clear drops the plan and the cache', () async {
      final cache = _MemoryCache();
      final repo = _repo(_Server(_response(_multiLine)), cache);
      await repo.refresh();

      await repo.clear();
      expect(repo.plan, isNull);
      expect(cache.body, isNull);
    });
  });

  group('WeeklyPlanScreen instructions card', () {
    setUpAll(_loadSegoeAsAppFont);

    testWidgets('multi-line response: card above the meals, one bullet per line', (tester) async {
      await _pumpPlan(tester, _repo(_Server(_response(_multiLine))));

      expect(find.text(_title), findsOneWidget);
      for (final line in [_line1, _line2, _line3]) {
        expect(find.text(line), findsOneWidget);
      }
      expect(find.text('عرض المزيد'), findsNothing);
      expect(
        tester.getTopLeft(find.text(_title)).dy,
        lessThan(tester.getTopLeft(find.text('الفطور').first).dy),
      );
    });

    for (final (label, instructions) in [('null', null), ('empty', ''), ('only spaces', '  \n \t\n ')]) {
      testWidgets('hidden entirely when the instructions are $label', (tester) async {
        await _pumpPlan(tester, _repo(_Server(_response(instructions))));

        expect(find.byType(PatientInstructionsCard), findsNothing);
        expect(find.text(_title), findsNothing);
      });
    }

    testWidgets('more than three lines sit behind "عرض المزيد"', (tester) async {
      await _pumpPlan(tester, _repo(_Server(_response('$_multiLine\nالسطر الرابع\nالسطر الخامس'))));

      expect(find.text(_line3), findsOneWidget);
      expect(find.text('السطر الرابع'), findsNothing);

      await tester.tap(find.text('عرض المزيد'));
      await _settle(tester);
      expect(find.text('السطر الرابع'), findsOneWidget);
      expect(find.text('السطر الخامس'), findsOneWidget);

      await tester.tap(find.text('عرض أقل'));
      await _settle(tester);
      expect(find.text('السطر الرابع'), findsNothing);
    });

    testWidgets('pull-to-refresh shows the new text', (tester) async {
      final server = _Server(_response(_multiLine));
      await _pumpPlan(tester, _repo(server));

      server.body = _response('تعليمات محدّثة');
      await tester.fling(find.byType(ListView).first, const Offset(0, 1000), 1000);
      await _settle(tester);

      expect(find.text('تعليمات محدّثة'), findsOneWidget);
      expect(find.text(_line1), findsNothing);
    });

    testWidgets('a plan-updated push (repository refresh) updates the open screen', (tester) async {
      final server = _Server(_response(null));
      final repo = _repo(server);
      await _pumpPlan(tester, repo);
      expect(find.text(_title), findsNothing);

      server.body = _response(_line2);
      await tester.runAsync(repo.refresh);
      await tester.pump();

      expect(find.text(_line2), findsOneWidget);
    });

    testWidgets('offline: shows the cached instructions, and a failed pull says so', (tester) async {
      final cache = _MemoryCache()..body = jsonEncode(_response(_multiLine));
      await _pumpPlan(tester, _repo(_Server(Exception('offline')), cache));

      expect(find.text(_title), findsOneWidget);
      expect(find.text(_line1), findsOneWidget);

      await tester.fling(find.byType(ListView).first, const Offset(0, 1000), 1000);
      await _settle(tester);
      expect(find.text(_line1), findsOneWidget);
      expect(find.textContaining('تعذّر تحديث الخطة'), findsOneWidget);
    });
  });

  testWidgets('a 2000-character line is shown whole on the narrowest phone', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 2000);
    addTearDown(tester.view.reset);
    final long = List.filled(400, 'نص طويل').join(' ').substring(0, 2000);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: PatientInstructionsCard(lines: [long]))),
    ));

    expect(tester.takeException(), isNull);
    final text = tester.widget<Text>(find.text(long));
    expect(text.maxLines, isNull);
    expect(text.overflow, isNull);
  });
}
