/// `YYYY-MM-DD` for a calendar date. The API takes date-only fields in this
/// form (API guide 1.2). The date parts of [date] are used as they are, so
/// pass the patient's own date.
String dateOnly(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  final year = date.year.toString().padLeft(4, '0');
  return '$year-${two(date.month)}-${two(date.day)}';
}

/// True when [a] and [b] fall on the same calendar day on this device. "Today"
/// on the patient's own screens means the device's day; the server's day is
/// the clinic's (API guide 1.2) and is not used here.
bool isSameLocalDay(DateTime a, DateTime b) {
  final x = a.toLocal();
  final y = b.toLocal();
  return x.year == y.year && x.month == y.month && x.day == y.day;
}
