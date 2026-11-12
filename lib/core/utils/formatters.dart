/// Number/string formatting helpers, consolidated from the per-screen
/// private copies (`_fmt` / `_d`) that previously existed in four files.
///
/// The app writes Latin digits (0-9) in both languages, as the web dashboard
/// does: Arabic text with Latin figures. [toLatinDigits] is the one place that
/// turns any other digits (Arabic-Indic from a platform date, Persian) into
/// them, and [useLatinDigits] makes Flutter's own date formatting do the same.
library;

import 'package:intl/intl.dart';

const String _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
const String _easternDigits = '۰۱۲۳۴۵۶۷۸۹';

/// [value] with Arabic-Indic and Persian digits written as Latin digits.
/// Everything else is left as it is.
String toLatinDigits(Object value) {
  final buf = StringBuffer();
  for (final unit in '$value'.runes) {
    final ch = String.fromCharCode(unit);
    var i = _arabicIndicDigits.indexOf(ch);
    if (i == -1) i = _easternDigits.indexOf(ch);
    buf.write(i == -1 ? ch : '$i');
  }
  return buf.toString();
}

/// Makes the Arabic dates Flutter and intl format (pickers, month names with
/// a day, years) use Latin digits too. Call once at start-up, and in a test
/// that shows a date.
void useLatinDigits() => DateFormat.useNativeDigitsByDefaultFor('ar', false);

/// Groups digits in threes with commas: `1234567` → `1,234,567`.
String formatThousands(num value) {
  final negative = value.isNegative;
  final s = value.abs().toString();
  final dot = s.indexOf('.');
  final intPart = dot == -1 ? s : s.substring(0, dot);
  final fracPart = dot == -1 ? '' : s.substring(dot);
  final buf = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
    buf.write(intPart[i]);
  }
  return '${negative ? '-' : ''}$buf$fracPart';
}

/// Plural-ish helper for Arabic counting nouns (1 → singular, 2 → dual,
/// 3–10 → plural, matching the phrasing the screens already use).
String arabicCountLabel(int count,
    {required String one, required String two, required String many}) {
  if (count == 1) return one;
  if (count == 2) return two;
  return many;
}

/// [date] as day/month/year with Western digits. Pass the result through
/// `context.localizeDigits` to show it in the active language's digits.
String numericDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}
