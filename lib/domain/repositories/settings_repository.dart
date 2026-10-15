import 'package:flutter/material.dart';

import '../../core/errors/result.dart';

/// User preferences (theme + language), persisted locally.
abstract interface class SettingsRepository {
  Future<Result<ThemeMode>> getThemeMode();
  Future<Result<void>> setThemeMode(ThemeMode mode);

  Future<Result<Locale?>> getLocale();
  Future<Result<void>> setLocale(Locale? locale);
}
