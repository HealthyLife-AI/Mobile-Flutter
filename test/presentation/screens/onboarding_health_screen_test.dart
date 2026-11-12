import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/domain/condition_codes.dart';
import 'package:healthylife_ai/domain/entities/patient_care_entities.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/health_profile_labels.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_health_screen.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_notifications_screen.dart';
import 'package:healthylife_ai/presentation/widgets/gradient_cta_button.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';
import '../../helpers/scripted_api.dart';

void main() {
  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  Future<void> open(WidgetTester tester, ScriptedApi api) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 4200);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(appProviders(
      const OnboardingHealthScreen(),
      dependencies: AppDependencies.inMemory(api: api),
      theme: AppTheme.light,
    ));
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  GradientCtaButton cta(WidgetTester tester) =>
      tester.widget<GradientCtaButton>(find.byType(GradientCtaButton));

  /// Fills the step: one condition, one allergy as an intolerance, one
  /// medication and a note.
  Future<void> fill(WidgetTester tester) async {
    await tester.tap(find.text('سكري النوع الثاني'));
    await tester.tap(find.text('البيض'));
    await tester.pump();
    await tester.tap(find.text('عدم تحمّل'));
    await tester.enterText(find.byType(TextField).first, 'Metformin 500mg');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    // Adding the medication drops the keyboard; let it go first.
    await tester.pump();
    await tester.enterText(find.byType(TextField).last, 'عملية مرارة سابقة');
    await tester.pump();
  }

  testWidgets('nothing is chosen for the patient', (tester) async {
    await open(tester, ScriptedApi());

    expect(find.text('متفورمين (Metformin) 500mg'), findsNothing);
    expect(cta(tester).onPressed, isNull,
        reason: 'a condition, or "none", has to be chosen first');
  });

  testWidgets('what the patient enters reaches the nutritionist (11.2)',
      (tester) async {
    final api = ScriptedApi({
      'POST me/proposals': {'id': 1, 'status': 'pending'},
      'POST me/quick-requests': {'id': 9, 'reason': 'other', 'status': 'open'},
    });
    await open(tester, api);

    await fill(tester);
    await tester.tap(find.byType(GradientCtaButton));
    await settle(tester);

    expect(api.to('POST', 'me/proposals').map((r) => r.body), [
      {
        'kind': 'allergy',
        'action': 'add',
        'data': {'group': 'egg', 'class': 'intolerance'},
      },
      {
        'kind': 'medication',
        'action': 'add',
        'data': {'name': 'Metformin 500mg'},
      },
    ]);
    final request = api.to('POST', 'me/quick-requests').single.body! as Map;
    expect(request['reason'], 'other');
    expect(request['note'], contains('سكري النوع الثاني'));
    expect(request['note'], startsWith('الحالات الصحية (من الإعداد الأولي):'));
    expect(request['note'], contains('عملية مرارة سابقة'));
    expect(find.byType(OnboardingNotificationsScreen), findsOneWidget);
  });

  testWidgets('a failure stays here, and a retry sends only what is left',
      (tester) async {
    var proposals = 0;
    final api = ScriptedApi({
      'POST me/proposals': (SentRequest _) => ++proposals == 2
          ? const NetworkException('offline', kind: NetworkFailureKind.offline)
          : {'id': proposals, 'status': 'pending'},
      'POST me/quick-requests': {'id': 9, 'reason': 'other', 'status': 'open'},
    });
    await open(tester, api);
    await fill(tester);

    await tester.tap(find.byType(GradientCtaButton));
    await settle(tester);
    expect(find.byType(OnboardingNotificationsScreen), findsNothing);
    expect(api.to('POST', 'me/quick-requests'), isEmpty);

    // The error notice lies over the button, so it is pressed directly.
    cta(tester).onPressed!();
    await settle(tester);

    final kinds = [
      for (final r in api.to('POST', 'me/proposals')) (r.body! as Map)['kind'],
    ];
    expect(kinds, ['allergy', 'medication', 'medication'],
        reason: 'the allergy went through the first time');
    expect(api.to('POST', 'me/quick-requests'), hasLength(1));
    expect(find.byType(OnboardingNotificationsScreen), findsOneWidget);
  });

  testWidgets('an allergy already on the profile counts as sent',
      (tester) async {
    final api = ScriptedApi({
      'POST me/proposals': const ApiException('recorded',
          statusCode: 409, code: 'already_recorded'),
    });
    await open(tester, api);

    await tester.tap(find.text('لا توجد حالات صحية مشخّصة'));
    await tester.tap(find.text('البيض'));
    await tester.pump();
    await tester.tap(find.byType(GradientCtaButton));
    await settle(tester);

    expect(api.to('POST', 'me/quick-requests'), isEmpty,
        reason: 'no condition and no note: nothing to tell');
    expect(find.byType(OnboardingNotificationsScreen), findsOneWidget);
  });

  group('conditions', () {
    final ar = lookupAppLocalizations(const Locale('ar'));
    final en = lookupAppLocalizations(const Locale('en'));

    test('are the server\'s codes, each with a label in both languages', () {
      // The same list, in the same order, as ConditionCodes::CODES in the
      // backend (app/Support/ConditionCodes.php).
      expect(conditionCodes, [
        'diabetes_type1',
        'diabetes_type2',
        'gestational_diabetes',
        'insulin_resistance',
        'prediabetes',
        'hypertension',
        'kidney_disease',
        'liver_disease',
        'cancer',
        'celiac',
        'fluid_retention',
        'other',
      ]);
      for (final code in conditionCodes) {
        expect(conditionLabel(ar, code), isNotNull, reason: code);
        expect(conditionLabel(en, code), isNotNull, reason: code);
      }
    });

    testWidgets('every coded condition is offered, and nothing else',
        (tester) async {
      await open(tester, ScriptedApi());
      for (final code in conditionCodes) {
        expect(find.text(conditionLabel(ar, code)!), findsOneWidget,
            reason: code);
      }
      // Conditions the server has no code for are typed under "other".
      expect(find.textContaining('PCOS'), findsNothing);
      expect(find.textContaining('IBS'), findsNothing);
    });

    testWidgets('"other" needs its text, which reaches the nutritionist',
        (tester) async {
      final api = ScriptedApi({
        'POST me/quick-requests': {
          'id': 9,
          'reason': 'other',
          'status': 'open'
        },
      });
      await open(tester, api);

      await tester.tap(find.text(ar.conditionOther));
      await tester.pump();
      expect(cta(tester).onPressed, isNull,
          reason: 'the choice alone says nothing');

      await tester.enterText(
          find.byKey(const Key('other-condition')), 'قصور الغدة الدرقية');
      await tester.pump();
      cta(tester).onPressed!();
      await settle(tester);

      final request = api.to('POST', 'me/quick-requests').single.body! as Map;
      expect(request['note'], contains('أخرى: قصور الغدة الدرقية'));
      expect(find.byType(OnboardingNotificationsScreen), findsOneWidget);
    });

    testWidgets('a note that does not fit is not sent, and nothing is cut',
        (tester) async {
      final api = ScriptedApi({
        'POST me/quick-requests': {
          'id': 9,
          'reason': 'other',
          'status': 'open'
        },
      });
      await open(tester, api);

      // Every condition, plus long notes: more than one note can carry.
      for (final code in conditionCodes) {
        await tester.tap(find.text(conditionLabel(ar, code)!));
      }
      await tester.pump();
      await tester.enterText(
          find.byKey(const Key('other-condition')), 'قصور الغدة الدرقية');
      final notes = 'ملاحظة ' * 20;
      await tester.enterText(find.byType(TextField).last, notes);
      await tester.pump();

      expect(find.byKey(const Key('note-too-long')), findsOneWidget);
      cta(tester).onPressed!();
      await settle(tester);
      expect(api.to('POST', 'me/quick-requests'), isEmpty);
      expect(find.byType(OnboardingNotificationsScreen), findsNothing);

      // Shorter notes fit, and the whole text goes out.
      await tester.enterText(find.byType(TextField).last, 'حامل');
      await tester.pump();
      expect(find.byKey(const Key('note-too-long')), findsNothing);
      cta(tester).onPressed!();
      await settle(tester);
      final note = (api.to('POST', 'me/quick-requests').single.body!
          as Map)['note'] as String;
      expect(note.length, lessThanOrEqualTo(QuickRequestDraft.noteMaxLength));
      expect(note, contains('قصور الغدة الدرقية'));
      expect(note, endsWith('ملاحظات: حامل'));
    });

    test('every coded condition together still leaves room for "other"', () {
      for (final l10n in [ar, en]) {
        final note = OnboardingHealthNote.compose(
          conditions: [
            for (final code in conditionCodes)
              if (code != 'other') conditionLabel(l10n, code)!,
          ],
          other: conditionLabel(l10n, 'other'),
          otherText: 'x' * OnboardingHealthNote.otherMaxLength,
          separator: l10n.commonListSeparator,
          conditionsLine: l10n.onboardingHealthRequestConditions,
          notesLine: l10n.onboardingHealthRequestNotes,
        )!;
        expect(note.fits, isTrue, reason: '${note.text.length} characters');
      }
    });
  });
}
