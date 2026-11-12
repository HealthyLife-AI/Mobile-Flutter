import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/network/auth_tokens.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/bloc/auth/auth_cubit.dart';
import 'package:healthylife_ai/presentation/screens/new_measurement_screen.dart';
import 'package:healthylife_ai/presentation/screens/profile_screen.dart';
import 'package:healthylife_ai/presentation/screens/quantity_selector_screen.dart';
import 'package:healthylife_ai/presentation/widgets/app_version_text.dart';

import '../helpers/app_font.dart';
import '../helpers/app_providers.dart';
import '../helpers/localized_app.dart';
import '../helpers/scripted_api.dart';

/// Nothing a patient reads may be a placeholder: these values used to be
/// fixed text (a sample patient code, a sample date, a sample food tag, a
/// typed-in version) and now come from the account, the clock and the build.
void main() {
  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  Map<String, Object?> me({String? code}) => {
        'id': 5,
        'name': 'سارة',
        'role': 'client',
        'nutritionist_id': 2,
        'subscriber_id': 17,
        'patient_code': code,
        'username': 'sara17',
        'password_is_temporary': false,
      };

  Future<void> pumpSignedIn(
    WidgetTester tester,
    Widget screen, {
    String? code,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1600);
    addTearDown(tester.view.reset);
    final api = ScriptedApi({
      'POST auth/refresh': {
        'access_token': 'a2',
        'refresh_token': 'r2',
        'token_type': 'Bearer',
        'expires_in': 900,
      },
      'GET auth/me': me(code: code),
      'GET me/consent': {'current_version': '1', 'accepted_version': '1'},
    });
    final deps = AppDependencies.inMemory(api: api);
    await tester.runAsync(() => deps.session.save(StoredSession(
          tokens: const AuthTokens(accessToken: 'a', refreshToken: 'r'),
          user: PatientUser(id: 5, name: 'سارة', patientCode: code),
          onboardingCompleted: true,
        )));
    var started = false;
    await tester.pumpWidget(appProviders(
      Builder(builder: (context) {
        if (!started) {
          started = true;
          context.read<AuthCubit>().start();
        }
        return screen;
      }),
      dependencies: deps,
      theme: AppTheme.light,
    ));
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 5)));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
  }

  testWidgets('the account screen shows the patient\'s own code',
      (tester) async {
    await pumpSignedIn(tester, const ProfileScreen(), code: 'HL-0317');
    expect(find.textContaining('HL-0317'), findsOneWidget);
    expect(find.textContaining('HL-0042'), findsNothing);
    await unmount(tester);
  });

  testWidgets('the account screen shows no code when the account has none',
      (tester) async {
    await pumpSignedIn(tester, const ProfileScreen());
    final ar = lookupAppLocalizations(const Locale('ar'));
    final label = ar.profilePatientCode('').trim();
    expect(find.textContaining(label), findsNothing);
    expect(find.textContaining('HL-'), findsNothing);
    await unmount(tester);
  });

  testWidgets('the new measurement screen shows today\'s date', (tester) async {
    await pumpSignedIn(tester, const MeasurementEntryScreen());
    final context = tester.element(find.byType(MeasurementEntryScreen));
    final today = context.localizeDigits(
        MaterialLocalizations.of(context).formatFullDate(DateTime.now()));
    expect(
        find.text(context.l10n.measurementEntryToday(today)), findsOneWidget);
    expect(find.textContaining('2025'), findsNothing);
    await unmount(tester);
  });

  testWidgets('a food carries no made-up tag on the quantity screen',
      (tester) async {
    await pumpSignedIn(
      tester,
      const QuantitySelectorScreen(
        food: SearchableFood(
            id: 7,
            name: 'صدر دجاج مشوي',
            caloriesPer100g: 165,
            macro: 'protein'),
      ),
    );
    expect(find.text('صدر دجاج مشوي'), findsWidgets);
    expect(find.textContaining('فاكهة'), findsNothing);
    await unmount(tester);
  });

  testWidgets('the version line shows the installed version, or nothing',
      (tester) async {
    await tester.pumpWidget(localizedApp(
      home: Builder(
        builder: (context) => Column(children: [
          AppVersionText(
            builder: context.l10n.aboutVersion,
            future: Future.value('2.3.1 (17)'),
          ),
          AppVersionText(
            key: const Key('unknown'),
            builder: context.l10n.aboutVersion,
            future: Future.value(null),
          ),
        ]),
      ),
    ));
    await tester.pump();
    expect(find.textContaining('2.3.1 (17)'), findsOneWidget);
    expect(
      find.descendant(
          of: find.byKey(const Key('unknown')), matching: find.byType(Text)),
      findsNothing,
    );
  });

  test('no string carries an internal screen code or a sample value', () {
    final internalCode = RegExp(r'\(?\bP-\d+\)?');
    for (final file in const ['lib/l10n/app_ar.arb', 'lib/l10n/app_en.arb']) {
      final text = File(file).readAsStringSync();
      expect(internalCode.hasMatch(text), isFalse,
          reason: '$file shows an internal screen code');
      expect(text.contains('HL-0042'), isFalse, reason: file);
      expect(text.contains('Build 240'), isFalse, reason: file);
    }
  });
}
