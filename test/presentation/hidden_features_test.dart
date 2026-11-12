import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/config/feature_flags.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/screens/food_search_screen.dart';
import 'package:healthylife_ai/presentation/screens/profile_screen.dart';

import '../helpers/app_font.dart';
import '../helpers/app_providers.dart';

/// The barcode scanner and the Health app link are not part of this release:
/// with the default build nothing on screen leads to them.
void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));

  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 3000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(appProviders(screen, theme: AppTheme.light));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
  }

  test('both features are off unless the build turns them on', () {
    expect(FeatureFlags.barcodeScanner, isFalse);
    expect(FeatureFlags.healthSync, isFalse);
  });

  testWidgets('food search offers no barcode scanner', (tester) async {
    await pump(tester, const FoodSearchScreen());
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsNothing);
    expect(find.bySemanticsLabel(ar.foodSearchScanBarcode), findsNothing);
    await unmount(tester);
  });

  testWidgets('the account screen offers no Health app link', (tester) async {
    await pump(tester, const ProfileScreen());
    // "More" holds the secondary entries; open it before looking.
    await tester.tap(find.text(ar.profileMore));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text(ar.profileAchievements), findsOneWidget);
    expect(find.text(ar.healthSyncTitle), findsNothing);
    await unmount(tester);
  });
}
