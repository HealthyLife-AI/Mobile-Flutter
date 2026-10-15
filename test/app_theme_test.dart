import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthylife_ai/core/theme/app_colors.dart';
import 'package:healthylife_ai/core/theme/app_radius.dart';
import 'package:healthylife_ai/core/theme/app_shadows.dart';
import 'package:healthylife_ai/core/theme/app_text_styles.dart';
import 'package:healthylife_ai/core/theme/app_theme.dart';
import 'package:healthylife_ai/core/theme/app_theme_colors.dart';

/// `AppTheme.light` exactly as it was defined before the design-system pass.
/// The refactored light theme must match it everywhere except the component
/// themes and extension that were deliberately added.
ThemeData _preDesignSystemLight() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.cardTitle,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.neutralTrack,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: AppTextStyles.h1,
        titleMedium: AppTextStyles.sectionHeading,
        bodyLarge: AppTextStyles.body,
        bodySmall: AppTextStyles.secondary,
      ),
      dividerColor: AppColors.borderLight,
    );

/// WCAG 2.x contrast ratio.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return ((la > lb ? la : lb) + 0.05) / ((la > lb ? lb : la) + 0.05);
}

const Set<WidgetState> _selected = {WidgetState.selected};
const Set<WidgetState> _idle = {};

void main() {
  group('light theme preserves the pre-design-system look', () {
    final light = AppTheme.light;
    final frozen = _preDesignSystemLight();

    test('nothing in ThemeData changed except the deliberate additions', () {
      final normalized = light.copyWith(
        // Closures can't compare equal; their resolved values are checked below.
        switchTheme: frozen.switchTheme,
        // Added in the design-system pass (no-ops for existing screens, which
        // was verified pixel-for-pixel against pre-refactor renders).
        filledButtonTheme: frozen.filledButtonTheme,
        elevatedButtonTheme: frozen.elevatedButtonTheme,
        outlinedButtonTheme: frozen.outlinedButtonTheme,
        floatingActionButtonTheme: frozen.floatingActionButtonTheme,
        bottomSheetTheme: frozen.bottomSheetTheme,
        dialogTheme: frozen.dialogTheme,
        extensions: frozen.extensions.values,
      );
      expect(normalized, frozen);
    });

    test('switch colors resolve exactly as before', () {
      for (final states in [_selected, _idle]) {
        expect(light.switchTheme.thumbColor!.resolve(states),
            frozen.switchTheme.thumbColor!.resolve(states));
        expect(light.switchTheme.trackColor!.resolve(states),
            frozen.switchTheme.trackColor!.resolve(states));
      }
      expect(light.switchTheme.trackOutlineColor!.resolve(_idle),
          Colors.transparent);
    });

    test('is light, on the brand canvas, with the Tajawal family', () {
      expect(light.brightness, Brightness.light);
      expect(light.scaffoldBackgroundColor, AppColors.background);
      expect(light.colorScheme.primary, AppColors.primary);
      expect(light.textTheme.bodyLarge!.fontFamily, AppTextStyles.fontFamily);
    });
  });

  group('dark theme', () {
    final dark = AppTheme.dark;

    test('is dark and built from AppDarkColors', () {
      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, AppDarkColors.background);
      expect(dark.colorScheme.primary, AppDarkColors.primary);
      expect(dark.colorScheme.onPrimary, AppDarkColors.onPrimary);
      expect(dark.colorScheme.surface, AppDarkColors.surface);
      expect(dark.colorScheme.onSurface, AppDarkColors.textPrimary);
      expect(dark.colorScheme.error, AppDarkColors.danger);
      expect(dark.appBarTheme.backgroundColor, AppDarkColors.surface);
      expect(dark.cardTheme.color, AppDarkColors.surface);
    });

    test('text roles switch to the light-on-dark text colors', () {
      expect(dark.textTheme.headlineMedium!.color, AppDarkColors.textPrimary);
      expect(dark.textTheme.titleMedium!.color, AppDarkColors.textPrimary);
      expect(dark.textTheme.bodyLarge!.color, AppDarkColors.textPrimary);
      expect(dark.textTheme.bodySmall!.color, AppDarkColors.textSecondary);
      expect(dark.appBarTheme.titleTextStyle!.color, AppDarkColors.textPrimary);
    });

    test('meets WCAG AA contrast for text and the 3:1 UI threshold', () {
      const bg = AppDarkColors.background;
      const surface = AppDarkColors.surface;
      final aa = <String, double>{
        'text on background': _contrast(AppDarkColors.textPrimary, bg),
        'text on surface': _contrast(AppDarkColors.textPrimary, surface),
        'secondary on background': _contrast(AppDarkColors.textSecondary, bg),
        'secondary on surface': _contrast(AppDarkColors.textSecondary, surface),
        'accent on background': _contrast(AppDarkColors.primary, bg),
        'accent on surface': _contrast(AppDarkColors.primary, surface),
        'danger on surface': _contrast(AppDarkColors.danger, surface),
        'onPrimary on accent':
            _contrast(AppDarkColors.onPrimary, AppDarkColors.primary),
        'white on brand fill': _contrast(Colors.white, AppColors.primary),
      };
      aa.forEach((pair, ratio) =>
          expect(ratio, greaterThanOrEqualTo(4.5), reason: pair));
      expect(_contrast(AppDarkColors.iconMuted, surface),
          greaterThanOrEqualTo(3.0));
      expect(_contrast(AppDarkColors.primary, AppDarkColors.primaryTint),
          greaterThanOrEqualTo(3.0));
    });
  });

  group('both themes share one design language', () {
    final themes = {'light': AppTheme.light, 'dark': AppTheme.dark};

    test('same typography metrics; only colors differ', () {
      TextStyle s(ThemeData t, TextStyle? Function(TextTheme) pick) =>
          pick(t.textTheme)!;
      for (final pick in <TextStyle? Function(TextTheme)>[
        (t) => t.headlineMedium,
        (t) => t.titleMedium,
        (t) => t.bodyLarge,
        (t) => t.bodySmall,
      ]) {
        final l = s(AppTheme.light, pick), d = s(AppTheme.dark, pick);
        expect(d.fontFamily, l.fontFamily);
        expect(d.fontSize, l.fontSize);
        expect(d.fontWeight, l.fontWeight);
        expect(d.height, l.height);
      }
    });

    themes.forEach((name, theme) {
      final colors = theme.extension<AppThemeColors>()!;

      test('$name: buttons follow the existing call-site styles', () {
        final filled = theme.filledButtonTheme.style!;
        expect(filled.backgroundColor!.resolve(_idle), AppColors.primary);
        expect(filled.foregroundColor!.resolve(_idle), Colors.white);
        expect(filled.elevation!.resolve(_idle), AppElevation.flat);
        expect(
            filled.shape!.resolve(_idle),
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button)));
        final label = filled.textStyle!.resolve(_idle)!;
        expect(label.fontFamily, AppTextStyles.fontFamily);
        expect(label.fontSize, 13);
        expect(label.fontWeight, FontWeight.w700);

        final elevated = theme.elevatedButtonTheme.style!;
        expect(elevated.backgroundColor!.resolve(_idle), AppColors.primary);
        expect(elevated.elevation!.resolve(_idle), AppElevation.flat);
        expect(
            elevated.shape!.resolve(_idle),
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill)));

        final outlined = theme.outlinedButtonTheme.style!;
        expect(outlined.side!.resolve(_idle)!.color, colors.border);

        expect(
            theme.floatingActionButtonTheme.backgroundColor, AppColors.primary);
        expect(theme.floatingActionButtonTheme.elevation, AppElevation.fab);
      });

      test('$name: sheets, dialogs and cards use the shared tokens', () {
        expect(theme.bottomSheetTheme.backgroundColor, colors.background);
        expect(
            theme.bottomSheetTheme.shape,
            const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.sheet))));
        expect(theme.dialogTheme.backgroundColor, colors.background);
        expect(
            theme.dialogTheme.shape,
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sheet)));
        expect(theme.cardTheme.color, colors.surface);
        expect(
            theme.cardTheme.shape,
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card)));
      });
    });
  });

  group('AppThemeColors extension', () {
    test('light is exactly the existing AppColors palette', () {
      const c = AppThemeColors.light;
      expect(c.primary, AppColors.primary);
      expect(c.primaryTint, AppColors.primaryTint);
      expect(c.primarySoftBg, AppColors.primarySoftBg);
      expect(c.background, AppColors.background);
      expect(c.canvasSoft, AppColors.canvasSoft);
      expect(c.surface, AppColors.surface);
      expect(c.textPrimary, AppColors.textPrimary);
      expect(c.textSecondary, AppColors.textSecondary);
      expect(c.border, AppColors.border);
      expect(c.hairline, AppColors.hairline);
      expect(c.iconMuted, AppColors.iconMuted);
      expect(c.chipInactiveBg, AppColors.chipInactiveBg);
      expect(c.neutralTrack, AppColors.neutralTrack);
      expect(c.danger, AppColors.danger);
    });

    test('each theme registers its own palette', () {
      expect(AppTheme.light.extension<AppThemeColors>(),
          same(AppThemeColors.light));
      expect(
          AppTheme.dark.extension<AppThemeColors>(), same(AppThemeColors.dark));
    });

    test('lerp and copyWith behave like a ThemeExtension should', () {
      const l = AppThemeColors.light, d = AppThemeColors.dark;
      expect(l.lerp(d, 0).background, l.background);
      expect(l.lerp(d, 1).background, d.background);
      expect(l.lerp(d, 0.5).surface, Color.lerp(l.surface, d.surface, 0.5));
      expect(l.lerp(null, 0.5), same(l));
      final tweaked = l.copyWith(danger: Colors.purple);
      expect(tweaked.danger, Colors.purple);
      expect(tweaked.surface, l.surface);
    });

    testWidgets('context.appColors follows the active theme', (tester) async {
      late AppThemeColors seen;
      Widget probe(ThemeData? theme) => MaterialApp(
            theme: theme,
            home: Builder(builder: (context) {
              seen = context.appColors;
              return const SizedBox();
            }),
          );

      await tester.pumpWidget(probe(AppTheme.dark));
      expect(seen.background, AppDarkColors.background);
      await tester.pumpWidget(probe(ThemeData())); // no extension registered
      await tester.pumpAndSettle(); // MaterialApp animates theme changes
      expect(seen.background, AppColors.background);
    });
  });

  group('shadows', () {
    test('the soft shadow is the original spec, now immutable', () {
      expect(AppShadows.soft, [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ]);
      expect(AppTheme.softShadow, same(AppShadows.soft));
    });
  });

  group('fonts', () {
    test('every font asset declared in pubspec.yaml exists', () {
      // Tajawal is requested by family name only; the moment font files are
      // declared, they must actually be in the repo.
      final declared = RegExp(r'^\s*-\s*asset:\s*(\S+)', multiLine: true)
          .allMatches(File('pubspec.yaml').readAsStringSync())
          .map((m) => m.group(1)!);
      for (final asset in declared) {
        expect(File(asset).existsSync(), isTrue, reason: '$asset is missing');
      }
    });

    test('the theme and every token request the same family', () {
      expect(AppTheme.light.textTheme.bodyLarge!.fontFamily, 'Tajawal');
      expect(AppTheme.dark.textTheme.bodyLarge!.fontFamily, 'Tajawal');
      for (final style in [
        AppTextStyles.h1,
        AppTextStyles.sectionHeading,
        AppTextStyles.cardTitle,
        AppTextStyles.body,
        AppTextStyles.secondary,
        AppTextStyles.caption,
        AppTextStyles.metricLarge,
        AppTextStyles.metricMedium,
        AppTextStyles.pillLabel,
        AppTextStyles.ctaText,
      ]) {
        expect(style.fontFamily, AppTextStyles.fontFamily);
      }
    });
  });
}
