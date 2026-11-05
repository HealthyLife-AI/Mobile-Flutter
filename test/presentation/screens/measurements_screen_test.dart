import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/presentation/screens/measurements_screen.dart';

import '../../helpers/app_font.dart';
import '../../helpers/app_providers.dart';
import '../../helpers/scripted_api.dart';

void main() {
  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  testWidgets('only the patient\'s own reading can be deleted (7.3)',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 3200);
    addTearDown(tester.view.reset);
    final until =
        DateTime.now().toUtc().add(const Duration(days: 5)).toIso8601String();
    final api = ScriptedApi({
      'GET me/measurements': [
        {
          'id': 8,
          'recorded_at': '2026-10-01',
          'source': 'clinic-analyser',
          'weight_kg': 84,
          'deletable_until': null,
        },
        {
          'id': 9,
          'recorded_at': '2026-10-06',
          'source': 'self-reported',
          'weight_kg': 82.5,
          'deletable_until': until,
        },
      ],
      'DELETE me/measurements/9': null,
    });
    await tester.pumpWidget(appProviders(
      const MeasurementsScreen(),
      dependencies: AppDependencies.inMemory(api: api),
      theme: AppTheme.light,
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final delete = find.byTooltip('حذف القراءة');
    expect(find.text('سجل القراءات'), findsOneWidget);
    expect(delete, findsOneWidget, reason: 'the clinic reading has none');

    await tester.ensureVisible(delete);
    await tester.tap(delete);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('حذف القراءة').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(api.to('DELETE', 'me/measurements/9'), hasLength(1));
  });
}
