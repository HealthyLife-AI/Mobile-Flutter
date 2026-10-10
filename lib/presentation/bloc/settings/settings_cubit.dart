import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/result.dart';
import '../../../domain/repositories/settings_repository.dart';

/// UI state for user preferences (theme + language), persisted through
/// [SettingsRepository]. The app defaults to Arabic + system theme until
/// the user picks something else.
@immutable
class SettingsState {
  const SettingsState({this.themeMode = ThemeMode.system, this.locale, this.loaded = false});

  final ThemeMode themeMode;
  final Locale? locale; // null → app default (ar)
  final bool loaded;

  Locale get effectiveLocale => locale ?? const Locale('ar');

  SettingsState copyWith({ThemeMode? themeMode, Locale? locale, bool? loaded, bool clearLocale = false}) =>
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

  Future<void> _load() async {
    final theme = await _repository.getThemeMode();
    final locale = await _repository.getLocale();
    if (isClosed) return;
    emit(state.copyWith(
      themeMode: theme.valueOrNull ?? ThemeMode.system,
      locale: locale.valueOrNull,
      loaded: true,
    ));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state.themeMode) return;
    emit(state.copyWith(themeMode: mode));
    final result = await _repository.setThemeMode(mode);
    if (result case Failed<void>(:final failure)) {
      // Roll back to the last persisted value if storage failed.
      debugPrint('Settings: theme persist failed (${failure.debugMessage})');
      final persisted = await _repository.getThemeMode();
      if (!isClosed) emit(state.copyWith(themeMode: persisted.valueOrNull ?? state.themeMode));
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == state.locale) return;
    emit(state.copyWith(locale: locale));
    final result = await _repository.setLocale(locale);
    if (result case Failed<void>(:final failure)) {
      debugPrint('Settings: locale persist failed (${failure.debugMessage})');
      final persisted = await _repository.getLocale();
      if (!isClosed) emit(state.copyWith(locale: persisted.valueOrNull));
    }
  }
}
