import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/presentation/screens/new_measurement_screen.dart';
import 'package:healthylife_ai/presentation/screens/quick_request_screen.dart';
import 'package:healthylife_ai/presentation/widgets/unsaved_changes_guard.dart';

import '../helpers/app_font.dart';
import '../helpers/localized_app.dart';
import '../helpers/screen_fixtures.dart';

const _phone = Size(360, 800);

/// A page the test can open and leave, with a flag standing in for typed text.
Widget _host({required bool Function() dirty}) => localizedApp(
      locale: const Locale('en'),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => UnsavedChangesGuard(
                  hasChanges: dirty,
                  child: const Scaffold(body: Text('the form')),
                ),
              )),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

Future<void> _openAndGoBack(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(find.text('the form'), findsOneWidget);
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(await loadAppFont(), isTrue);
    await loadMaterialIcons();
  });

  testWidgets('an untouched form leaves at once', (tester) async {
    await tester.pumpWidget(_host(dirty: () => false));
    await _openAndGoBack(tester);
    expect(find.text('the form'), findsNothing);
    expect(find.text('Discard changes?'), findsNothing);
  });

  testWidgets('a typed-into form asks, and staying keeps it', (tester) async {
    await tester.pumpWidget(_host(dirty: () => true));
    await _openAndGoBack(tester);
    expect(find.text('Discard changes?'), findsOneWidget);

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('the form'), findsOneWidget);
    expect(find.text('Discard changes?'), findsNothing);
  });

  testWidgets('discarding leaves the form', (tester) async {
    await tester.pumpWidget(_host(dirty: () => true));
    await _openAndGoBack(tester);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('the form'), findsNothing);
  });

  testWidgets('a quick request with a note asks before it is dropped',
      (tester) async {
    await pumpScreen(tester, _phone, (_) => const QuickRequestScreen(),
        locale: const Locale('en'));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing,
        reason: 'nothing typed yet');

    await pumpScreen(tester, _phone, (_) => const QuickRequestScreen(),
        locale: const Locale('en'));
    await tester.enterText(find.byType(TextField).first, 'a note');
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('a measurement with a weight asks before it is dropped',
      (tester) async {
    await pumpScreen(tester, _phone, (_) => const MeasurementEntryScreen(),
        locale: const Locale('en'));
    await tester.tap(find.bySemanticsLabel('Increase').first,
        warnIfMissed: false);
    await tester.tap(find.byIcon(Icons.add_rounded).first,
        warnIfMissed: false);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
  });
}
