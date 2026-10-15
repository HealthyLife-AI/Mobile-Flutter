import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/result.dart';
import '../../../domain/repositories/settings_repository.dart';
import '../../../l10n/l10n.dart';

/// UI state for user preferences (theme + language), persisted through
/// [SettingsRepository]. The app defaults to Arabic + the light theme until
/// the user picks something else (dark mode is opt-in, never inherited from
/// the device setting).
@immutable
class SettingsState {
  const SettingsState(
      {this.themeMode = ThemeMode.light, this.locale, this.loaded = false});

  /// The app language until the user picks another one. Never taken from
  /// the device locale.
  static const Locale defaultLocale = Locale('ar');

  final ThemeMode themeMode;
  final Locale? locale; // null → app default (ar)
  final bool loaded;

  /// The language the app renders in: the user's choice when it is a
  /// supported one, otherwise [defaultLocale].
  Locale get effectiveLocale => supportedLocaleOrNull(locale) ?? defaultLocale;

  /// [locale] reduced to the matching supported app language (`en_US` →
  /// `en`), or null when the app does not support it.
  static Locale? supportedLocaleOrNull(Locale? locale) {
    if (locale == null) return null;
    for (final supported in AppLocalizations.supportedLocales) {
      if (supported.languageCode == locale.languageCode) return supported;
    }
    return null;
  }

  SettingsState copyWith(
          {ThemeMode? themeMode,
          Locale? locale,
          bool? loaded,
          bool clearLocale = false}) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: clearLocale ? null : (locale ?? this.locale),
        loaded: loaded ?? this.loaded,
      );
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState()) {
    _load();
  }

  final SettingsRepository _repository;

  // Set by the setters: a choice made while [_load] is still reading storage
  // is newer than the stored value it reads, so it must not be overwritten.
  bool _themeChosen = false;
  bool _localeChosen = false;

  Future<void> _load() async {
    final theme = await _repository.getThemeMode();
    final locale = await _repository.getLocale();
    if (isClosed) return;
    emit(SettingsState(
      themeMode: _themeChosen
          ? state.themeMode
          : (theme.valueOrNull ?? ThemeMode.light),
      locale: _localeChosen
          ? state.locale
          : SettingsState.supportedLocaleOrNull(locale.valueOrNull),
      loaded: true,
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state.themeMode) return;
    _themeChosen = true;
    emit(state.copyWith(themeMode: mode));
    final result = await _repository.setThemeMode(mode);
    if (result case Failed<void>(:final failure)) {
      // Roll back to the last persisted value if storage failed.
      debugPrint('Settings: theme persist failed (${failure.debugMessage})');
      final persisted = await _repository.getThemeMode();
      if (!isClosed) {
        emit(state.copyWith(
            themeMode: persisted.valueOrNull ?? state.themeMode));
      }
    }
  }

  /// Switches the app language and persists the choice. null — or a
  /// language the app does not support — means the default, Arabic.
  Future<void> setLocale(Locale? locale) async {
    final next = SettingsState.supportedLocaleOrNull(locale);
    if (next == state.locale) return;
    _localeChosen = true;
    emit(state.copyWith(locale: next, clearLocale: next == null));
    final result = await _repository.setLocale(next);
    if (result case Failed<void>(:final failure)) {
      // Roll back to the last persisted value if storage failed. If even
      // that cannot be read, keep the choice for this session.
      debugPrint('Settings: locale persist failed (${failure.debugMessage})');
      final persisted = await _repository.getLocale();
      if (persisted case Success<Locale?>(:final value) when !isClosed) {
        final restored = SettingsState.supportedLocaleOrNull(value);
        emit(state.copyWith(locale: restored, clearLocale: restored == null));
      }
    }
  }
}
