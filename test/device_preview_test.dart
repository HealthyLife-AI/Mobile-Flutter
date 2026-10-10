import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthylife_ai/main.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_measurements_screen.dart';

/// Deliberately trivial home: SplashScreen's self-rescheduling status timer and
/// never-ending particle animation make any widget test of the real root
/// unable to settle. These tests are about the DevicePreview wiring, not about
/// SplashScreen's motion.
const Widget _probeHome = Scaffold(body: Center(child: Text('probe')));

/// Mirrors the DevicePreview configuration in `main()`.
Widget wrapPreview({bool enabled = true}) {
  return DevicePreview(
    enabled: enabled,
    // No shared_preferences channel in tests.
    storage: DevicePreviewStorage.none(),
    devices: [Devices.ios.iPhoneSE, Devices.ios.iPhone13],
    defaultDevice: Devices.ios.iPhone13,
    availableLocales: const [Locale('ar'), Locale('en')],
    builder: (_) => const HealthyLifeApp(home: _probeHome),
  );
}

void main() {
  testWidgets('app builds inside DevicePreview without tripping its assert', (tester) async {
    await tester.pumpWidget(wrapPreview());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('probe'), findsOneWidget);
  });

  testWidgets('the device frame renders the app, not just the toolbar', (tester) async {
    await tester.pumpWidget(wrapPreview());
    await tester.pump();

    expect(find.byType(DeviceFrame), findsOneWidget);
  });

  testWidgets('disabled preview bypasses the frame and the toolbar entirely', (tester) async {
    await tester.pumpWidget(wrapPreview(enabled: false));
    await tester.pump();

    expect(find.byType(DeviceFrame), findsNothing);
    expect(tester.takeException(), isNull);
    expect(find.text('probe'), findsOneWidget);
  });

  testWidgets('app stays RTL even though DevicePreview wraps in LTR', (tester) async {
    await tester.pumpWidget(wrapPreview());
    await tester.pump();

    // DevicePreview hardcodes Directionality.ltr around the whole preview, so
    // the app has to re-assert RTL itself or all Arabic text mirrors.
    final rtl = tester
        .widgetList<Directionality>(find.byType(Directionality))
        .any((d) => d.textDirection == TextDirection.rtl);
    expect(rtl, isTrue);
  });

  testWidgets('app inherits the simulated device size, not the test window', (tester) async {
    await tester.pumpWidget(wrapPreview());
    await tester.pump();

    // iPhone 13 is 390x844 logical px; the default test surface is 800x600.
    // This is what useInheritedMediaQuery is there to guarantee.
    final appContext = tester.element(find.text('probe'));
    expect(MediaQuery.sizeOf(appContext), const Size(390, 844));
  });

  testWidgets('weight selector opens a scrollable picker when tapped', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingMeasurementsScreen()));
    await tester.tap(find.byKey(const ValueKey('weight_selector_trigger')));
    // Not pumpAndSettle: the CTA/shine controllers loop forever, so settle
    // never returns. Two pumps cover the picker's entry transition.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('اختر وزنك'), findsOneWidget);
    expect(find.byType(ListWheelScrollView), findsOneWidget);
  });
}
