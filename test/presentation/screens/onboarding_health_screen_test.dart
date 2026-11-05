import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
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
    await tester.tap(find.text('السكري (النوع الأول / الثاني)'));
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
    expect(request['note'], contains('السكري'));
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

    await tester.tap(find.text('لا توجد لدي أي أمراض مزمنة'));
    await tester.tap(find.text('البيض'));
    await tester.pump();
    await tester.tap(find.byType(GradientCtaButton));
    await settle(tester);

    expect(api.to('POST', 'me/quick-requests'), isEmpty,
        reason: 'no condition and no note: nothing to tell');
    expect(find.byType(OnboardingNotificationsScreen), findsOneWidget);
  });
}
