import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/presentation/screens/login_screen.dart';
import 'package:healthylife_ai/presentation/widgets/gradient_cta_button.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';
import '../../helpers/scripted_api.dart';

void main() {
  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  group('lockCountdown', () {
    test('reads minutes and two-digit seconds', () {
      expect(lockCountdown(const Duration(seconds: 90)), (1, '30'));
      expect(lockCountdown(const Duration(minutes: 15)), (15, '00'));
    });

    test('rounds up, so it never reads 0:00 while locked', () {
      expect(lockCountdown(const Duration(milliseconds: 1)), (0, '01'));
      expect(lockCountdown(const Duration(milliseconds: 59001)), (1, '00'));
    });
  });

  Future<AppDependencies> open(WidgetTester tester, ScriptedApi api) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 1400);
    addTearDown(tester.view.reset);
    final deps = AppDependencies.inMemory(api: api);
    await tester.pumpWidget(appProviders(
      const LoginScreen(),
      dependencies: deps,
      theme: AppTheme.light,
    ));
    await tester.pump();
    return deps;
  }

  testWidgets('a locked sign-in (423) counts down and cannot be sent',
      (tester) async {
    final until = DateTime.now().toUtc().add(const Duration(minutes: 2));
    final api = ScriptedApi({
      'POST auth/login': ApiException('Locked',
          statusCode: 423, body: {'locked_until': until.toIso8601String()}),
    });
    await open(tester, api);

    await tester.enterText(find.byType(TextField).at(0), 'sara.k');
    await tester.enterText(find.byType(TextField).at(1), 'Kd7mZp3Rtq');
    await tester.tap(find.byType(GradientCtaButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('تم إيقاف الدخول مؤقتًا'), findsOneWidget);
    expect(
        tester
            .widget<GradientCtaButton>(find.byType(GradientCtaButton))
            .onPressed,
        isNull);
  });

  testWidgets('forgot password offers WhatsApp with a kept number (3.6)',
      (tester) async {
    final deps = await open(tester, ScriptedApi());
    await deps.passwordHelp.remember('+970599123456');

    await tester.tap(find.text('نسيت كلمة المرور؟'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('اطلب من أخصائيك'), findsOneWidget);
    expect(find.text('فتح واتساب'), findsOneWidget);
  });

  testWidgets('forgot password has no WhatsApp without a kept number',
      (tester) async {
    await open(tester, ScriptedApi());

    await tester.tap(find.text('نسيت كلمة المرور؟'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('اطلب من أخصائيك'), findsOneWidget);
    expect(find.text('فتح واتساب'), findsNothing);
  });
}
