import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

/// Date wording shared by the patient-app spec screens. Digits follow the app
/// language (Arabic-Indic in Arabic), like the rest of the app.

/// Whole calendar days from [a] to [b] (positive when [b] is later).
int calendarDaysBetween(DateTime a, DateTime b) =>
    DateTime.utc(b.year, b.month, b.day)
        .difference(DateTime.utc(a.year, a.month, a.day))
        .inDays;

/// "الأحد، 9 نوفمبر": weekday, day and month, with the year only when it is
/// not this year.
String fullDayLabel(BuildContext context, DateTime date) {
  final material = MaterialLocalizations.of(context);
  return context.localizeDigits(date.year == DateTime.now().year
      ? material.formatMediumDate(date)
      : material.formatFullDate(date));
}

/// "9 نوفمبر" (with the year when it is not this year).
String shortDateLabel(BuildContext context, DateTime date) {
  final material = MaterialLocalizations.of(context);
  return context.localizeDigits(date.year == DateTime.now().year
      ? material.formatShortMonthDay(date)
      : material.formatShortDate(date));
}

/// "اليوم" / "أمس" / a short date.
String relativeDayLabel(BuildContext context, DateTime date) {
  final days = calendarDaysBetween(date, DateTime.now());
  if (days == 0) return context.l10n.commonToday;
  if (days == 1) return context.l10n.commonYesterday;
  return shortDateLabel(context, date);
}

/// "اليوم، 9:20 م".
String dayAndTimeLabel(BuildContext context, DateTime at) {
  final local = at.toLocal();
  final time = MaterialLocalizations.of(context)
      .formatTimeOfDay(TimeOfDay.fromDateTime(local));
  final separator = context.isArabic ? '، ' : ', ';
  return '${relativeDayLabel(context, local)}$separator'
      '${context.localizeDigits(time)}';
}
