import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/core/theme/app_colors.dart';
import 'package:healthylife_ai/core/network/auth_tokens.dart';
import 'package:healthylife_ai/core/theme/app_theme_colors.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';
import 'package:healthylife_ai/domain/repositories/settings_repository.dart';
import 'package:healthylife_ai/main.dart';
import 'package:healthylife_ai/presentation/bloc/settings/settings_cubit.dart';

const Widget _probe = Scaffold(body: Text('probe'));

/// Mounts the real app root around a trivial home and lets the stored
/// preference load and any theme animation finish.
Future<void> _pumpApp(WidgetTester tester, AppDependencies deps) async {
  await tester.pumpWidget(HealthyLifeApp(dependencies: deps, home: _probe));
  await tester.pumpAndSettle();
}

ThemeData _activeTheme(WidgetTester tester) =>
    Theme.of(tester.element(find.text('probe')));

SettingsCubit _settings(WidgetTester tester) =>
    BlocProvider.of<SettingsCubit>(tester.element(find.text('probe')));

/// A settings store whose reads only resolve when [release] completes, to
/// force a user choice to land while the stored value is still loading.
class _SlowSettingsRepository implements SettingsRepository {
  final release = Completer<void>();
  ThemeMode stored = ThemeMode.light;

  @override
  Future<Result<ThemeMode>> getThemeMode() async {
    final snapshot = stored; // what storage held when the read was issued
    await release.future;
    return Success(snapshot);
  }

  @override
  Future<Result<void>> setThemeMode(ThemeMode mode) async {
    stored = mode;
    return const Success(null);
  }

  @override
  Future<Result<Locale?>> getLocale() async {
    await release.future;
    return const Success(null);
  }

  @override
  Future<Result<void>> setLocale(Locale? locale) async => const Success(null);
}

void main() {
  group('theme mode in the running app', () {
    testWidgets('defaults to the designed light theme', (tester) async {
      await _pumpApp(tester, AppDependencies.inMemory());

      expect(_activeTheme(tester).brightness, Brightness.light);
      expect(
          _activeTheme(tester).scaffoldBackgroundColor, AppColors.background);
      expect(_settings(tester).state.themeMode, ThemeMode.light);
    });

    testWidgets('stays light by default even when the device is dark',
        (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      await _pumpApp(tester, AppDependencies.inMemory());

      expect(_activeTheme(tester).brightness, Brightness.light);
    });

    testWidgets('switching to dark and back swaps the whole theme',
        (tester) async {
      await _pumpApp(tester, AppDependencies.inMemory());

      await _settings(tester).setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();
      final dark = _activeTheme(tester);
      expect(dark.brightness, Brightness.dark);
      expect(dark.scaffoldBackgroundColor, AppDarkColors.background);
      expect(dark.extension<AppThemeColors>()!.surface, AppDarkColors.surface);

      await _settings(tester).setThemeMode(ThemeMode.light);
      await tester.pumpAndSettle();
      expect(_activeTheme(tester).brightness, Brightness.light);
      expect(_activeTheme(tester).extension<AppThemeColors>()!.surface,
          AppColors.surface);
    });

    testWidgets('system mode follows the device brightness', (tester) async {
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      await _pumpApp(tester, AppDependencies.inMemory());

      await _settings(tester).setThemeMode(ThemeMode.system);
      await tester.pumpAndSettle();
      expect(_activeTheme(tester).brightness, Brightness.dark);

      tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(_activeTheme(tester).brightness, Brightness.light);
    });

    testWidgets('a stored dark preference is applied at startup',
        (tester) async {
      final deps = AppDependencies.inMemory();
      await deps.settings.setThemeMode(ThemeMode.dark);

      await _pumpApp(tester, deps);

      expect(_activeTheme(tester).brightness, Brightness.dark);
    });

    testWidgets('changing the mode persists it', (tester) async {
      final deps = AppDependencies.inMemory();
      await _pumpApp(tester, deps);

      await _settings(tester).setThemeMode(ThemeMode.dark);
      await tester.pumpAndSettle();

      expect((await deps.settings.getThemeMode()).valueOrNull, ThemeMode.dark);
    });
  });

  group('SettingsCubit', () {
    test('a choice made while the stored value is loading is kept', () async {
      final repo = _SlowSettingsRepository()..stored = ThemeMode.light;
      final cubit = SettingsCubit(repo);
      addTearDown(cubit.close);

      await cubit.setThemeMode(ThemeMode.dark); // load still pending
      repo.release.complete();
      await pumpEventQueue();

      expect(cubit.state.themeMode, ThemeMode.dark);
      expect(cubit.state.loaded, isTrue);
    });

    test('without a choice, the stored value wins once loaded', () async {
      final repo = _SlowSettingsRepository()..stored = ThemeMode.dark;
      final cubit = SettingsCubit(repo);
      addTearDown(cubit.close);

      expect(cubit.state.themeMode, ThemeMode.light); // default before load
      repo.release.complete();
      await pumpEventQueue();

      expect(cubit.state.themeMode, ThemeMode.dark);
    });
  });

  group('theme preference storage', () {
    test('round-trips through shared_preferences across graph rebuilds',
        () async {
      SharedPreferences.setMockInitialValues({});

      final first = await AppDependencies.create();
      await first.settings.setThemeMode(ThemeMode.dark);
      // A fresh graph over the same store: what main() builds next launch.
      final second = await AppDependencies.create();
      expect(
          (await second.settings.getThemeMode()).valueOrNull, ThemeMode.dark);

      await second.settings.setThemeMode(ThemeMode.system);
      final third = await AppDependencies.create();
      expect(
          (await third.settings.getThemeMode()).valueOrNull, ThemeMode.system);
    });

    test('missing or unknown stored values fall back to light', () async {
      final deps = AppDependencies.inMemory();
      expect((await deps.settings.getThemeMode()).valueOrNull, ThemeMode.light);

      await deps.storage.writeString(StorageKeys.themeMode, 'sepia');
      expect((await deps.settings.getThemeMode()).valueOrNull, ThemeMode.light);

      await deps.storage.writeString(StorageKeys.themeMode, 'light');
      expect((await deps.settings.getThemeMode()).valueOrNull, ThemeMode.light);
    });

    test('is a device preference: it survives logout', () async {
      final deps = AppDependencies.inMemory();
      await deps.session.save(const StoredSession(
        tokens: AuthTokens(accessToken: 'access', refreshToken: 'refresh'),
        user: PatientUser(id: 1, name: 'Test'),
        onboardingCompleted: true,
      ));
      await deps.settings.setThemeMode(ThemeMode.dark);

      await deps.auth.signOut();

      expect(await deps.session.read(), isNull);
      expect((await deps.settings.getThemeMode()).valueOrNull, ThemeMode.dark);
    });
  });
}
