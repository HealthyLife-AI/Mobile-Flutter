/// Number/string formatting helpers, consolidated from the per-screen
/// private copies (`_fmt` / `_d`) that previously existed in four files.
///
/// Arabic (RTL) locales render Arabic-Indic digits; Western locales render
/// plain digits — same behavior the screens hard-coded before, now driven by
/// the active locale.
library;

const String _westDigits = '0123456789';
const String _eastDigits = '٠١٢٣٤٥٦٧٨٩';

/// Converts Western digits in [value] to Arabic-Indic digits (non-digits are
/// left untouched).
String toArabicDigits(Object value) {
  final s = '$value';
  final buf = StringBuffer();
  for (final ch in s.split('')) {
    final i = _westDigits.indexOf(ch);
    buf.write(i == -1 ? ch : _eastDigits[i]);
  }
  return buf.toString();
}

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

/// Formats [value] for display in the given locale: grouped, and rendered
/// with Arabic-Indic digits when [useArabicDigits] is true.
String formatNumber(num value, {required bool useArabicDigits}) {
  final grouped = formatThousands(value);
  return useArabicDigits ? toArabicDigits(grouped) : grouped;
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
