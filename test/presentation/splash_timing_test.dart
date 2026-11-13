import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/network/auth_tokens.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';
import 'package:healthylife_ai/main.dart';
import 'package:healthylife_ai/presentation/screens/login_screen.dart';
import 'package:healthylife_ai/presentation/screens/splash_screen.dart';

import '../helpers/app_font.dart';
import '../helpers/screen_fixtures.dart';
import '../helpers/scripted_api.dart';

void main() {
  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  testWidgets('a signed-in patient is past the splash in about a second',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    final deps =
        AppDependencies.inMemory(api: ScriptedApi(screenRoutes()));
    await tester.runAsync(() => deps.session.save(const StoredSession(
          tokens: AuthTokens(accessToken: 'a', refreshToken: 'r'),
          user: screenUser,
          onboardingCompleted: false,
        )));

    await tester.pumpWidget(
        HealthyLifeApp(home: const SplashScreen(), dependencies: deps));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(SplashScreen), findsOneWidget,
        reason: 'the logo gets its moment');

    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(SplashScreen), findsNothing,
        reason: 'no three-second wait for someone who is signed in');
    expect(find.byType(LoginScreen), findsNothing);

    // Unmount so the screen's timers are disposed.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('nobody signed in still gets the full splash', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const HealthyLifeApp(home: SplashScreen()));
    await tester.pump(const Duration(milliseconds: 1600));
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
