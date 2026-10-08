import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthylife_ai/widgets/gradient_cta_button.dart';

void main() {
  Future<void> pumpOutlinedCta(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientCtaButton(
            label: 'بحث',
            outlined: true,
            onPressed: () {},
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('an outlined CTA disposes without ever animating its glow',
      (tester) async {
    await pumpOutlinedCta(tester);
    // The outlined variant returns from build before touching the glow
    // controller, so dispose() used to read (and therefore construct) it on a
    // deactivated element.
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a filled CTA disposes its glow controller cleanly',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GradientCtaButton(label: 'التالي', onPressed: () {}),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);
  });
}
