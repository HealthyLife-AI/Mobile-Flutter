// Controls that are only an icon need a name a screen reader can say, and a
// touch target of 48dp.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/presentation/screens/delete_account_screen.dart';
import 'package:healthylife_ai/presentation/screens/new_measurement_screen.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_measurements_screen.dart';
import 'package:healthylife_ai/presentation/screens/password_settings_screen.dart';

import '../helpers/app_font.dart';
import '../helpers/screen_fixtures.dart';

const _phone = Size(360, 800);

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 6));
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(await loadAppFont(), isTrue);
    await loadMaterialIcons();
  });

  for (final entry in const {
    'en': ['Show password', 'Hide password', 'Increase', 'Decrease'],
    'ar': [
      'إظهار كلمة المرور',
      'إخفاء كلمة المرور',
      'زيادة',
      'إنقاص',
    ],
  }.entries) {
    final show = entry.value[0];
    final increase = entry.value[2];
    final decrease = entry.value[3];
    final locale = Locale(entry.key);

    testWidgets('password fields say what the eye icon does (${entry.key})',
        (tester) async {
      final semantics = tester.ensureSemantics();
      // Tall, so all three fields are on screen.
      await pumpScreen(
          tester, const Size(360, 1400), (_) => const PasswordSettingsScreen(),
          locale: locale);
      expect(find.bySemanticsLabel(show), findsAtLeastNWidgets(2));
      await _unmount(tester);
      semantics.dispose();
    });

    testWidgets('delete-account password eye has a tooltip (${entry.key})',
        (tester) async {
      await pumpScreen(tester, _phone, (_) => const DeleteAccountScreen(),
          locale: locale);
      expect(find.byTooltip(show), findsOneWidget);
      await _unmount(tester);
    });

    testWidgets('the measurement steppers are named and 48dp (${entry.key})',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpScreen(tester, _phone, (_) => const MeasurementEntryScreen(),
          locale: locale);
      expect(find.bySemanticsLabel(increase), findsWidgets);
      expect(find.bySemanticsLabel(decrease), findsWidgets);
      final size = tester.getSize(find.bySemanticsLabel(increase).first);
      expect(size.shortestSide, greaterThanOrEqualTo(48));
      await _unmount(tester);
      semantics.dispose();
    });

    testWidgets('the first-measurement steppers are named (${entry.key})',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpScreen(
          tester, _phone, (_) => const OnboardingMeasurementsScreen(),
          locale: locale);
      expect(find.bySemanticsLabel(increase), findsWidgets);
      expect(find.bySemanticsLabel(decrease), findsWidgets);
      await _unmount(tester);
      semantics.dispose();
    });
  }
}
