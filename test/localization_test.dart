import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/data/repositories/settings_repository_impl.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/main.dart';
import 'package:healthylife_ai/presentation/bloc/auth/auth_cubit.dart';
import 'package:healthylife_ai/presentation/bloc/settings/settings_cubit.dart';
import 'package:healthylife_ai/presentation/screens/about_app_screen.dart';
import 'package:healthylife_ai/presentation/screens/achievements_screen.dart';
import 'package:healthylife_ai/presentation/screens/delete_account_screen.dart';
import 'package:healthylife_ai/presentation/screens/follow_up_ended_screen.dart';
import 'package:healthylife_ai/presentation/screens/language_settings_screen.dart';
import 'package:healthylife_ai/presentation/screens/login_screen.dart';
import 'package:healthylife_ai/presentation/screens/notification_settings_screen.dart';
import 'package:healthylife_ai/presentation/screens/onboarding_screen.dart';
import 'package:healthylife_ai/presentation/screens/privacy_document_screen.dart';
import 'package:healthylife_ai/presentation/screens/profile_screen.dart';
import 'package:healthylife_ai/presentation/widgets/app_header_bar.dart';

import 'helpers/localized_app.dart';

/// Phase 3 localization: Arabic by default, English on request, one locale
/// state (SettingsCubit) that persists, survives restarts and drives text and
/// direction without restarting the app.

final RegExp _arabicScript = RegExp(r'[؀-ۿݐ-ݿﭐ-﷿ﹰ-﻿]');

class _ProbeHome extends StatelessWidget {
  const _ProbeHome();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(child: Text(context.l10n.languageTitle)),
      );
}

/// Real app root around a trivial home; lets stored preferences load.
Future<void> _pumpApp(WidgetTester tester, AppDependencies deps,
    {Widget home = const _ProbeHome()}) async {
  await tester.pumpWidget(HealthyLifeApp(dependencies: deps, home: home));
  await tester.pumpAndSettle();
}

/// The probe home's context, also while another route covers it.
BuildContext _homeContext(WidgetTester tester) =>
    tester.element(find.byType(_ProbeHome, skipOffstage: false));

/// Loads the bundled Tajawal faces under the family the app requests, so
/// layouts measure real glyphs instead of the test font's full-em boxes.
Future<void> _loadTajawal() async {
  final loader = FontLoader('Tajawal');
  for (final face in ['Regular', 'Medium', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/Tajawal-$face.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Locale _activeLocale(WidgetTester tester) =>
    Localizations.localeOf(_homeContext(tester));

TextDirection _activeDirection(WidgetTester tester) =>
    Directionality.of(_homeContext(tester));

SettingsCubit _settings(WidgetTester tester) =>
    BlocProvider.of<SettingsCubit>(_homeContext(tester));

/// Storage whose reads always fail, like a broken shared-preferences plugin.
class _BrokenStorage extends MemoryStorageService {
  @override
  Future<String?> readString(String key) async =>
      throw const FileSystemException('storage unavailable');
}

void main() {
  final ar = lookupAppLocalizations(const Locale('ar'));
  final en = lookupAppLocalizations(const Locale('en'));

  setUpAll(_loadTajawal);

  group('locale defaults', () {
    testWidgets('a fresh installation starts in Arabic, right to left',
        (tester) async {
      await _pumpApp(tester, AppDependencies.inMemory());

      expect(_activeLocale(tester), const Locale('ar'));
      expect(_activeDirection(tester), TextDirection.rtl);
      expect(find.text(ar.languageTitle), findsOneWidget);
      expect(_settings(tester).state.locale, isNull,
          reason: 'nothing chosen yet: the app default applies');
    });

    testWidgets('the device locale never replaces the Arabic default',
        (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
      tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      addTearDown(tester.platformDispatcher.clearLocaleTestValue);

      await _pumpApp(tester, AppDependencies.inMemory());

      expect(_activeLocale(tester), const Locale('ar'));
      expect(_activeDirection(tester), TextDirection.rtl);
    });

    testWidgets('a saved English choice is restored at startup',
        (tester) async {
      final deps = AppDependencies.inMemory();
      await deps.storage.writeString(StorageKeys.locale, 'en');

      await _pumpApp(tester, deps);

      expect(_activeLocale(tester), const Locale('en'));
      expect(_activeDirection(tester), TextDirection.ltr);
      expect(find.text(en.languageTitle), findsOneWidget);
    });

    testWidgets('a saved Arabic choice is restored at startup', (tester) async {
      final deps = AppDependencies.inMemory();
      await deps.storage.writeString(StorageKeys.locale, 'ar');

      await _pumpApp(tester, deps);

      expect(_activeLocale(tester), const Locale('ar'));
      expect(_settings(tester).state.locale, const Locale('ar'));
    });

    for (final stored in ['fr', 'xx', '', 'English', 'en_US']) {
      testWidgets('an unsupported saved value ("$stored") falls back to Arabic',
          (tester) async {
        final deps = AppDependencies.inMemory();
        await deps.storage.writeString(StorageKeys.locale, stored);

        await _pumpApp(tester, deps);

        expect(_activeLocale(tester), const Locale('ar'));
        expect(_activeDirection(tester), TextDirection.rtl);
      });
    }

    test('unreadable storage starts in Arabic without throwing', () async {
      final cubit = SettingsCubit(SettingsRepositoryImpl(_BrokenStorage()));
      addTearDown(cubit.close);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.effectiveLocale, const Locale('ar'));
    });
  });

  group('switching language', () {
    testWidgets('selecting English, then Arabic, updates the running app',
        (tester) async {
      await _pumpApp(tester, AppDependencies.inMemory());

      await _settings(tester).setLocale(const Locale('en'));
      await tester.pumpAndSettle();
      expect(_activeLocale(tester), const Locale('en'));
      expect(_activeDirection(tester), TextDirection.ltr);
      expect(find.text(en.languageTitle), findsOneWidget);

      await _settings(tester).setLocale(const Locale('ar'));
      await tester.pumpAndSettle();
      expect(_activeLocale(tester), const Locale('ar'));
      expect(_activeDirection(tester), TextDirection.rtl);
      expect(find.text(ar.languageTitle), findsOneWidget);
    });

    testWidgets('switching keeps the navigation stack', (tester) async {
      await _pumpApp(tester, AppDependencies.inMemory());
      Navigator.of(_homeContext(tester)).push(MaterialPageRoute<void>(
          builder: (context) => Scaffold(body: Text(context.l10n.aboutTitle))));
      await tester.pumpAndSettle();
      expect(find.text(ar.aboutTitle), findsOneWidget);

      await _settings(tester).setLocale(const Locale('en'));
      await tester.pumpAndSettle();

      // Same pushed page, now in English, with the home still underneath.
      expect(find.text(en.aboutTitle), findsOneWidget);
      expect(find.byType(_ProbeHome, skipOffstage: false), findsOneWidget);
    });

    testWidgets('the choice survives a save-and-reload cycle', (tester) async {
      final deps = AppDependencies.inMemory();
      await _pumpApp(tester, deps);
      await _settings(tester).setLocale(const Locale('en'));
      await tester.pumpAndSettle();

      expect(await deps.storage.readString(StorageKeys.locale), 'en');

      // A new app on the same storage = the next launch.
      await tester.pumpWidget(const SizedBox());
      await _pumpApp(tester, deps);
      expect(_activeLocale(tester), const Locale('en'));
    });

    test('only supported languages are stored; region variants are reduced',
        () async {
      final deps = AppDependencies.inMemory();
      final cubit = SettingsCubit(deps.settings);
      addTearDown(cubit.close);

      await cubit.setLocale(const Locale('en', 'US'));
      expect(cubit.state.locale, const Locale('en'));
      expect(await deps.storage.readString(StorageKeys.locale), 'en');

      await cubit.setLocale(const Locale('fr'));
      expect(cubit.state.locale, isNull, reason: 'unsupported means default');
      expect(cubit.state.effectiveLocale, const Locale('ar'));

      await cubit.setLocale(const Locale('en'));
      await cubit.setLocale(null);
      expect(cubit.state.locale, isNull, reason: 'null clears the choice');
      expect(await deps.storage.readString(StorageKeys.locale), isNull);
    });

    testWidgets('switching does not touch the session or onboarding state',
        (tester) async {
      final deps = AppDependencies.inMemory();
      await deps.storage.writeString(StorageKeys.onboardingCompleted, 'true');
      await _pumpApp(tester, deps);
      final auth = BlocProvider.of<AuthCubit>(_homeContext(tester));
      final AuthState before = auth.state;

      await _settings(tester).setLocale(const Locale('en'));
      await tester.pumpAndSettle();

      expect(identical(auth.state, before), isTrue,
          reason: 'a language change must not emit auth states');
      expect(BlocProvider.of<AuthCubit>(_homeContext(tester)), same(auth));
      expect(await deps.storage.readString(StorageKeys.onboardingCompleted),
          'true');
    });

    testWidgets('the language screen applies the choice on save',
        (tester) async {
      final deps = AppDependencies.inMemory();
      await _pumpApp(tester, deps);
      // The save button's glow loops forever, so step frames instead of
      // waiting for the tree to settle.
      Future<void> settle() async {
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
      }

      Navigator.of(_homeContext(tester)).push(MaterialPageRoute<void>(
          builder: (_) => const LanguageSettingsScreen()));
      await settle();

      // Picking a card alone changes nothing.
      await tester.tap(find.text('English'));
      await settle();
      expect(_settings(tester).state.effectiveLocale, const Locale('ar'));

      await tester.scrollUntilVisible(find.text(ar.languageSave), 200,
          scrollable: find
              .descendant(
                  of: find.byType(LanguageSettingsScreen),
                  matching: find.byType(Scrollable))
              .first);
      await settle();
      await tester.tap(find.text(ar.languageSave));
      await settle();

      expect(find.byType(LanguageSettingsScreen), findsNothing,
          reason: 'saving returns to the previous screen');
      expect(_activeLocale(tester), const Locale('en'));
      expect(find.text(en.languageTitle), findsOneWidget);
      expect(await deps.storage.readString(StorageKeys.locale), 'en');
    });
  });

  group('localization resources', () {
    Map<String, dynamic> readArb(String name) =>
        jsonDecode(File('lib/l10n/$name').readAsStringSync())
            as Map<String, dynamic>;
    final arArb = readArb('app_ar.arb');
    final enArb = readArb('app_en.arb');
    Set<String> keys(Map<String, dynamic> arb) =>
        arb.keys.where((k) => !k.startsWith('@')).toSet();
    final placeholder = RegExp(r'\{(\w+)[,}]');

    test('both languages load and are the only supported ones', () {
      expect(AppLocalizations.supportedLocales,
          const [Locale('ar'), Locale('en')]);
      expect(ar.localeName, 'ar');
      expect(en.localeName, 'en');
    });

    test('Arabic and English define exactly the same messages', () {
      expect(keys(enArb), keys(arArb));
    });

    test('every message is non-empty and English has no Arabic script', () {
      for (final key in keys(arArb)) {
        expect((arArb[key] as String).trim(), isNotEmpty, reason: key);
        expect((enArb[key] as String).trim(), isNotEmpty, reason: key);
        expect(_arabicScript.hasMatch(enArb[key] as String), isFalse,
            reason: '$key: "${enArb[key]}"');
      }
    });

    test('placeholders match between the two languages', () {
      for (final key in keys(arArb)) {
        Set<String?> names(String s) =>
            placeholder.allMatches(s).map((m) => m[1]).toSet();
        expect(names(enArb[key] as String), names(arArb[key] as String),
            reason: key);
      }
    });

    test('generated code is current with the ARB files', () {
      final generated =
          File('lib/l10n/generated/app_localizations.dart').readAsStringSync();
      final members = RegExp(r'^  String (?:get )?(\w+)[;(]', multiLine: true)
          .allMatches(generated)
          .map((m) => m[1])
          .toSet();
      expect(members, keys(arArb),
          reason: 'run `flutter gen-l10n` after editing the ARB files');
      expect(
          File('lib/l10n/untranslated_messages.txt').readAsStringSync().trim(),
          '{}');
    });
  });

  group('Arabic plurals keep the original wording', () {
    // The hand-written rules the screens used before Phase 3. Digits are
    // passed separately (countText), so only the wording is compared.
    String meals(int n) => n == 1
        ? 'وجبة واحدة'
        : n == 2
            ? 'وجبتان'
            : '$n وجبات';
    String mealsAccusative(int n) => n == 1
        ? 'وجبة واحدة'
        : n == 2
            ? 'وجبتين'
            : '$n وجبات';
    String seconds(int n) => n <= 1
        ? 'ثانية واحدة'
        : n == 2
            ? 'ثانيتان'
            : '$n ثوانٍ';
    String redirect(int n) =>
        'جاري نقلك تلقائياً خلال $n ${n == 1 ? "ثانية" : "ثوانٍ"}…';
    String foods(int n) => n == 1
        ? 'طعام واحد'
        : n == 2
            ? 'طعامان'
            : (n >= 3 && n <= 10)
                ? '$n أطعمة'
                : '$n طعاماً';

    test('for every count the screens can show', () {
      for (var n = 0; n <= 120; n++) {
        expect(ar.dailyLogMealsCount(n, '$n'), meals(n), reason: 'meals $n');
        expect(ar.mealLoggedMealsCount(n, '$n'), mealsAccusative(n),
            reason: 'logged meals $n');
        expect(ar.redirectCountdown(n, '$n'), redirect(n),
            reason: 'redirect $n');
        expect(ar.notificationsNewCount(n, '$n'), 'لديك $n إشعارات جديدة');
        if (n >= 1) {
          expect(ar.mealLoggedCountdown(n, '$n'), seconds(n),
              reason: 'countdown $n');
        }
        // 103–110 follow the Arabic "few" rule (أطعمة), which the old
        // 3–10 check never reached; everything else is unchanged.
        final expectedFoods =
            (n % 100 >= 3 && n % 100 <= 10) ? '$n أطعمة' : foods(n);
        expect(ar.foodSearchFoodsCount(n, '$n'), expectedFoods,
            reason: 'foods $n');
      }
    });

    test('English plurals are grammatical', () {
      expect(en.dailyLogMealsCount(1, '1'), '1 meal');
      expect(en.dailyLogMealsCount(2, '2'), '2 meals');
      expect(en.notificationsNewCount(1, '1'), 'You have 1 new notification');
      expect(en.notificationsNewCount(3, '3'), 'You have 3 new notifications');
    });
  });

  group('directionality', () {
    for (final (locale, direction, back) in [
      (const Locale('ar'), TextDirection.rtl, Icons.arrow_forward_rounded),
      (const Locale('en'), TextDirection.ltr, Icons.arrow_back_rounded),
    ]) {
      testWidgets(
          '${locale.languageCode}: ${direction.name} layout, start-aligned '
          'text and the header back arrow', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.reset);
        final l10n = lookupAppLocalizations(locale);

        await tester.pumpWidget(localizedApp(
          locale: locale,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (_) => const AboutAppScreen())),
              child: const Text('open'),
            ),
          ),
        ));
        await tester.tap(find.text('open'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        final heading = find.text(l10n.aboutPrivacyPolicyTitle);
        expect(Directionality.of(tester.element(heading)), direction);
        expectTextHugsStartEdge(tester, heading, direction: direction);
        // The header back arrow reads ← in both languages: Arabic keeps the
        // design's mirrored arrow_forward, English uses arrow_back.
        expect(
            find.descendant(
                of: find.byType(AppHeaderBar), matching: find.byIcon(back)),
            findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      });
    }

    testWidgets('digits follow the language', (tester) async {
      late String arDigits, enDigits;
      for (final locale in const [Locale('ar'), Locale('en')]) {
        await tester.pumpWidget(localizedApp(
          locale: locale,
          home: Builder(builder: (context) {
            final s = context.localizeDigits(1250);
            locale.languageCode == 'ar' ? arDigits = s : enDigits = s;
            return const SizedBox();
          }),
        ));
      }
      expect(arDigits, '١٢٥٠');
      expect(enDigits, '1250');
    });
  });

  group('no Arabic left in the English interface', () {
    // Intentional Arabic in English mode: each language card names its own
    // language in its own script (Language screen).
    const allowed = {
      'العربية',
      'اتجاه القراءة',
      'من اليمين إلى اليسار',
      'الإنجليزية (current app language)',
      'الإنجليزية',
      'ا ب ت ث ج',
      'ح خ د ذ ر',
      'ز س ش ص ض',
      'ط ظ ع غ ف',
    };

    Set<String> visibleStrings(WidgetTester tester) => {
          for (final e in find.byType(RichText).evaluate())
            (e.widget as RichText).text.toPlainText(),
          for (final e in find.byType(EditableText).evaluate())
            (e.widget as EditableText).controller.text,
          for (final e in find.byType(TextField).evaluate()) ...[
            (e.widget as TextField).decoration?.hintText ?? '',
            (e.widget as TextField).decoration?.labelText ?? '',
          ],
          for (final e in find.byType(Tooltip).evaluate())
            (e.widget as Tooltip).message ?? '',
        };

    final screens = <String, Widget Function()>{
      'about': () => const AboutAppScreen(),
      'achievements': () => const AchievementsScreen(),
      'delete account': () => const DeleteAccountScreen(),
      'follow-up ended': () =>
          const FollowUpEndedScreen(followUp: FollowUpEnded.fallback),
      'language': () => const LanguageSettingsScreen(),
      'login': () => const LoginScreen(),
      'notification settings': () => const NotificationSettingsScreen(),
      'onboarding': () => const OnboardingScreen(),
      'privacy document': () => const PrivacyDocumentScreen(),
      'profile': () => const ProfileScreen(),
    };

    screens.forEach((name, build) {
      testWidgets(name, (tester) async {
        tester.view.devicePixelRatio = 2;
        tester.view.physicalSize = const Size(780, 1688);
        addTearDown(tester.view.reset);
        final deps = AppDependencies.inMemory();
        expect(await deps.settings.setLocale(const Locale('en')),
            isA<Success<void>>());

        await tester
            .pumpWidget(HealthyLifeApp(dependencies: deps, home: build()));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));

        final leftover = visibleStrings(tester)
            .where(_arabicScript.hasMatch)
            .where((s) => !allowed.contains(s))
            .toList();
        expect(leftover, isEmpty);

        // Unmount and let pending timers run out.
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });
    });
  });
}
