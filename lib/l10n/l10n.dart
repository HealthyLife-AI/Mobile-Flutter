import 'package:flutter/widgets.dart';

import '../core/utils/formatters.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// Widget-side access to the generated [AppLocalizations].
///
/// The active language comes from `SettingsCubit` through `MaterialApp.locale`
/// (Arabic unless the user picked English), so everything here follows the
/// one app-wide locale and rebuilds when it changes.
extension AppLocalizationsContext on BuildContext {
  /// `context.l10n.someKey` — the strings for the active language.
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// True while the app runs in Arabic (the default language).
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  /// [value] with Latin digits (0-9) in both languages. Other digits, such as
  /// the Arabic-Indic ones a platform date can carry, are converted; every
  /// other character is left as it is. Kept as a method on the context so a
  /// change of rule stays one line.
  String localizeDigits(Object value) => toLatinDigits(value);
}
