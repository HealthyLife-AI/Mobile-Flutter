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

  /// [value] with its digits written the way the active language writes them:
  /// Arabic-Indic in Arabic (exactly what the screens rendered before
  /// localization), Western in English. Only digits change — separators and
  /// any other characters are left as they are.
  String localizeDigits(Object value) =>
      isArabic ? toArabicDigits(value) : '$value';
}
