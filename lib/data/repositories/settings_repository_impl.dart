import 'package:flutter/material.dart';

import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._storage);

  final StorageService _storage;

  @override
  Future<Result<ThemeMode>> getThemeMode() => guard(
        () async {
          switch (await _storage.readString(StorageKeys.themeMode)) {
            case 'light':
              return ThemeMode.light;
            case 'dark':
              return ThemeMode.dark;
            default:
              return ThemeMode.system;
          }
        },
        context: 'SettingsRepository.getThemeMode',
      );

  @override
  Future<Result<void>> setThemeMode(ThemeMode mode) => guard(
        () async {
          await _storage.writeString(StorageKeys.themeMode, mode.name);
        },
        context: 'SettingsRepository.setThemeMode',
      );

  @override
  Future<Result<Locale?>> getLocale() => guard(
        () async {
          final raw = await _storage.readString(StorageKeys.locale);
          if (raw == null) return null; // not chosen yet → app default (ar)
          if (raw == 'en') return const Locale('en');
          if (raw == 'ar') return const Locale('ar');
          return null;
        },
        context: 'SettingsRepository.getLocale',
      );

  @override
  Future<Result<void>> setLocale(Locale? locale) => guard(
        () async {
          if (locale == null) {
            await _storage.remove(StorageKeys.locale);
          } else {
            await _storage.writeString(StorageKeys.locale, locale.languageCode);
          }
        },
        context: 'SettingsRepository.setLocale',
      );
}
