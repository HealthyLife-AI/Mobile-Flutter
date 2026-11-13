// "Log a meal" is the middle item of the bottom bar on every tab. There is no
// floating button, and no screen content sits under the bar.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/presentation/app_shell.dart';
import 'package:healthylife_ai/presentation/widgets/animated_bottom_nav_pill.dart';
import 'package:healthylife_ai/presentation/widgets/log_meal_sheet.dart';

import '../helpers/app_font.dart';
import '../helpers/screen_fixtures.dart';

const _phone = Size(360, 800);
const _tabIcons = [
  Icons.home_rounded,
  Icons.event_note_rounded,
  Icons.insights_rounded,
  Icons.person_rounded,
];

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    expect(await loadAppFont(), isTrue);
    await loadMaterialIcons();
  });

  for (var tab = 0; tab < _tabIcons.length; tab++) {
    testWidgets('tab $tab: the add button is in the bar and covers nothing',
        (tester) async {
      await pumpScreen(tester, _phone, (_) => const AppShell(),
          act: (t) async => t.tap(
              find.descendant(
                  of: find.byType(AnimatedBottomNavPill),
                  matching: find.byIcon(_tabIcons[tab])),
              warnIfMissed: false));

      expect(find.byType(FloatingActionButton), findsNothing);
      final add = find.byTooltip('تسجيل وجبة جديدة');
      expect(add, findsOneWidget);
      final bar = tester.getRect(find.byType(AnimatedBottomNavPill));
      expect(bar.contains(tester.getCenter(add)), isTrue);

      // The body ends where the bar starts: nothing is drawn under it.
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.extendBody, isFalse);
      expect(scaffold.floatingActionButton, isNull);

      await tester.tap(add);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(LogMealSheet), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 6));
    });
  }
}
