import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/widgets/app_header_bar.dart';
import 'package:healthylife_ai/presentation/widgets/load_error_view.dart';
import 'package:healthylife_ai/presentation/widgets/shimmer_box.dart';
import 'package:healthylife_ai/presentation/widgets/state_views.dart';

import '../../helpers/app_font.dart';
import '../../helpers/localized_app.dart';

void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));

  setUpAll(() async {
    expect(await loadAppFont(), isTrue);
  });

  Future<void> show(WidgetTester tester, Widget child,
      {Locale locale = const Locale('ar'), double scale = 1}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(
          size: const Size(360, 640), textScaler: TextScaler.linear(scale)),
      child: localizedApp(
        locale: locale,
        theme: AppTheme.light,
        home: Scaffold(body: child),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('LoadErrorView', () {
    testWidgets('says there is no connection, and retries', (tester) async {
      var retried = 0;
      await show(
        tester,
        LoadErrorView(
            failure: const NetworkFailure(), onRetry: () => retried++),
      );

      expect(find.text(ar.stateOfflineTitle), findsOneWidget);
      expect(find.text(ar.commonOfflineBody), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

      await tester.tap(find.text(ar.commonRetry));
      expect(retried, 1);
    });

    testWidgets('says something went wrong for any other failure',
        (tester) async {
      await show(
        tester,
        LoadErrorView(failure: const ServerFailure(), onRetry: () {}),
      );

      expect(find.text(ar.stateErrorTitle), findsOneWidget);
      expect(find.text(ar.commonErrorBody), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('the retry button is at least 48dp high', (tester) async {
      await show(tester, LoadErrorView(onRetry: () {}));

      final size = tester.getSize(find.byType(OutlinedButton));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('holds up at text scale 1.3 on a small phone', (tester) async {
      await show(
        tester,
        LoadErrorView(failure: const NetworkFailure(), onRetry: () {}),
        scale: 1.3,
      );

      expect(tester.takeException(), isNull);
      expect(find.text(ar.commonRetry), findsOneWidget);
    });
  });

  group('EmptyState', () {
    testWidgets('shows what will appear, and offers the way to add it',
        (tester) async {
      var tapped = false;
      await show(
        tester,
        EmptyState(
          title: 'لا توجد طلبات',
          message: 'ستظهر طلباتك وردود أخصائيك هنا.',
          actionLabel: 'طلب جديد',
          onAction: () => tapped = true,
        ),
      );

      expect(find.text('لا توجد طلبات'), findsOneWidget);
      expect(find.text('ستظهر طلباتك وردود أخصائيك هنا.'), findsOneWidget);
      await tester.tap(find.text('طلب جديد'));
      expect(tapped, isTrue);
    });

    testWidgets('has no button without an action', (tester) async {
      await show(tester, const EmptyState(title: 'لا توجد عناصر'));

      expect(find.byType(OutlinedButton), findsNothing);
    });
  });

  group('ListSkeleton', () {
    testWidgets('is a skeleton, not a spinner, and says it is loading',
        (tester) async {
      await show(tester, const ListSkeleton());

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.bySemanticsLabel(ar.commonLoading), findsOneWidget);
      // The boxes have a real size: a skeleton that measured 0 wide would
      // show nothing at all.
      final boxes = find.byType(ShimmerBox);
      expect(boxes, findsNWidgets(4));
      for (final box in tester.widgetList<ShimmerBox>(boxes).indexed) {
        final size = tester.getSize(boxes.at(box.$1));
        expect(size.width, greaterThan(300));
        expect(size.height, 88);
      }
    });
  });

  group('header', () {
    testWidgets('the back button is 48dp and named for a screen reader',
        (tester) async {
      await show(
        tester,
        const AppHeaderBar(title: 'القياسات'),
      );

      // Whichever arrow the language uses: the tappable area is the button.
      final button = find.descendant(
          of: find.byType(AppHeaderBar), matching: find.byType(InkWell));
      expect(button, findsOneWidget);
      final size = tester.getSize(button);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(find.byTooltip('رجوع'), findsOneWidget);
    });
  });

  test('no screen waits behind a full-page spinner', () {
    // A page that loads shows a skeleton (ListSkeleton) in the shape of its
    // content, so the layout does not jump when the data arrives.
    final spinner = RegExp(
        r'Center\(\s*child:\s*(const\s+)?CircularProgressIndicator\(\)\s*\)');
    final offenders = [
      for (final file
          in Directory('lib/presentation').listSync(recursive: true))
        if (file is File &&
            file.path.endsWith('.dart') &&
            spinner.hasMatch(file.readAsStringSync()) &&
            !file.path.endsWith('state_views.dart'))
          file.path,
    ];
    // The few inline spinners (a card loading, a page footer) are written
    // inside a Padding and are not full-page.
    expect(offenders.where((path) => !_inlineSpinnerFiles.any(path.endsWith)),
        isEmpty);
  });
}

/// Files that still show a small inline spinner, not a full page.
const _inlineSpinnerFiles = [
  'progress_screen.dart',
  'posts_screens.dart',
  'schedule_calls_screen.dart',
  'book_appointment_screen.dart',
];
