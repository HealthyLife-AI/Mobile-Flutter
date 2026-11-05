import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthylife_ai/core/theme/app_colors.dart';
import 'package:healthylife_ai/core/theme/app_radius.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/presentation/widgets/animated_bottom_nav_pill.dart';
import 'package:healthylife_ai/presentation/widgets/app_header_bar.dart';
import 'package:healthylife_ai/presentation/widgets/confirm_action_sheet.dart';
import 'package:healthylife_ai/presentation/widgets/gradient_cta_button.dart';
import 'helpers/localized_app.dart';

Widget _host(Widget child, {ThemeData? theme}) => localizedApp(
      theme: theme ?? AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

const _tabs = [
  NavTab(icon: Icons.home_rounded, label: 'الرئيسية'),
  NavTab(icon: Icons.event_note_rounded, label: 'الخطة'),
  NavTab(icon: Icons.person_rounded, label: 'حسابي'),
];

/// Opens a [ConfirmActionSheet] and returns a future of its result.
Future<Future<bool?>> _openSheet(WidgetTester tester,
    {bool destructive = true}) async {
  late Future<bool?> result;
  await tester.pumpWidget(_host(Builder(
    builder: (context) => TextButton(
      onPressed: () => result = ConfirmActionSheet.show(
        context,
        icon: Icons.logout_rounded,
        title: 'تسجيل الخروج من الحساب',
        message: 'رسالة',
        confirmLabel: 'تأكيد الخروج',
        destructive: destructive,
      ),
      child: const Text('open'),
    ),
  )));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  group('ConfirmActionSheet (logout confirmation)', () {
    testWidgets('confirm resolves true', (tester) async {
      final result = await _openSheet(tester);
      await tester.tap(find.text('تأكيد الخروج'));
      await tester.pumpAndSettle();
      expect(await result, isTrue);
    });

    testWidgets('cancel resolves false', (tester) async {
      final result = await _openSheet(tester);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(await result, isFalse);
    });

    testWidgets('dismissing via the barrier resolves null', (tester) async {
      final result = await _openSheet(tester);
      await tester.tapAt(const Offset(20, 20)); // above the sheet
      await tester.pumpAndSettle();
      expect(await result, isNull);
    });

    testWidgets('destructive uses the danger accent, otherwise primary',
        (tester) async {
      await _openSheet(tester);
      expect(tester.widget<Icon>(find.byIcon(Icons.logout_rounded)).color,
          AppColors.danger);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();

      await _openSheet(tester, destructive: false);
      expect(tester.widget<Icon>(find.byIcon(Icons.logout_rounded)).color,
          AppColors.primary);
    });

    testWidgets('renders on the canvas color with 24px top corners',
        (tester) async {
      await _openSheet(tester);
      final panel = tester.widget<Container>(find
          .descendant(
              of: find.byType(ConfirmActionSheet),
              matching: find.byType(Container))
          .first);
      final decoration = panel.decoration! as BoxDecoration;
      expect(decoration.color, AppColors.background);
      expect(decoration.borderRadius,
          const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)));
    });
  });

  group('GradientCtaButton', () {
    testWidgets('shows its label and fires once per tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
          _host(GradientCtaButton(label: 'متابعة', onPressed: () => taps++)));
      await tester.tap(find.text('متابعة'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(taps, 1);
    });

    testWidgets('without a callback it is disabled and dimmed', (tester) async {
      await tester.pumpWidget(_host(const GradientCtaButton(label: 'متابعة')));
      await tester.tap(find.text('متابعة'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 300));
      final dim = tester.widget<Opacity>(find
          .descendant(
              of: find.byType(GradientCtaButton),
              matching: find.byType(Opacity))
          .first);
      expect(dim.opacity, 0.5);
    });

    testWidgets('while loading it shows progress and ignores taps',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(GradientCtaButton(
          label: 'متابعة', loading: true, onPressed: () => taps++)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(GradientCtaButton));
      await tester.pump(const Duration(milliseconds: 300));
      expect(taps, 0);
    });

    testWidgets('the outlined variant is a pill-shaped OutlinedButton',
        (tester) async {
      var taps = 0;
      await tester.pumpWidget(_host(GradientCtaButton(
          label: 'بحث', outlined: true, onPressed: () => taps++)));
      expect(find.byType(OutlinedButton), findsOneWidget);
      await tester.tap(find.text('بحث'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(taps, 1);
    });
  });

  group('AppHeaderBar', () {
    testWidgets('shows the title and its back action pops the route',
        (tester) async {
      await tester.pumpWidget(localizedApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const Scaffold(
                appBar: AppHeaderBar(title: 'حول التطبيق'),
                body: SizedBox(),
              ),
            )),
            child: const Text('go'),
          ),
        ),
      ));
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      expect(find.text('حول التطبيق'), findsOneWidget);

      // Arabic: the design's back glyph (mirrored arrow_forward, i.e. ←).
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();
      expect(find.text('حول التطبيق'), findsNothing);
      expect(find.text('go'), findsOneWidget);
    });

    testWidgets('is the flat surface app bar of the design', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
            appBar: AppHeaderBar(title: 'العنوان', showBack: false)),
      ));
      await tester.pumpAndSettle();
      final bar = tester.widget<AppBar>(find.byType(AppBar));
      expect(bar.backgroundColor, AppColors.surface);
      expect(bar.elevation, 0);
      expect(bar.scrolledUnderElevation, 0);
    });
  });

  group('AnimatedBottomNavPill', () {
    testWidgets('renders every tab and reports taps by index', (tester) async {
      final tapped = <int>[];
      await tester.pumpWidget(_host(AnimatedBottomNavPill(
          tabs: _tabs, selectedIndex: 0, onChanged: tapped.add)));
      for (final tab in _tabs) {
        expect(find.byIcon(tab.icon), findsOneWidget);
      }
      await tester.tap(find.byIcon(Icons.person_rounded));
      await tester.tap(find.byIcon(Icons.event_note_rounded));
      expect(tapped, [2, 1]);
    });
  });

  group('shared components under the dark theme', () {
    testWidgets('build without errors', (tester) async {
      await tester.pumpWidget(_host(
        theme: AppTheme.dark,
        Column(mainAxisSize: MainAxisSize.min, children: [
          GradientCtaButton(label: 'متابعة', onPressed: () {}),
          GradientCtaButton(label: 'بحث', outlined: true, onPressed: () {}),
          AnimatedBottomNavPill(
              tabs: _tabs, selectedIndex: 1, onChanged: (_) {}),
        ]),
      ));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);

      final result = await _openSheet(tester);
      expect(find.byType(ConfirmActionSheet), findsOneWidget);
      await tester.tap(find.text('إلغاء'));
      await tester.pumpAndSettle();
      expect(await result, isFalse);
    });
  });
}
