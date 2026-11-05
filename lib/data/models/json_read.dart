/// Lenient readers for API JSON, shared by the patient-app spec features.
///
/// Each returns null (or empty) for a missing or mistyped value instead of
/// throwing, so one odd field never hides a whole screen.
library;

int? jsonInt(Object? value) {
  if (value is int) return value;
  if (value is num && value == value.roundToDouble()) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

double? jsonDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

/// A trimmed, non-empty string.
String? jsonText(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

/// A string kept exactly as sent (blank lines included), or null when empty.
String? jsonBody(Object? value) =>
    value is String && value.trim().isNotEmpty ? value : null;

bool? jsonBool(Object? value) => value is bool ? value : null;

/// A calendar date (`2026-11-09`) as a local midnight. A full timestamp is
/// reduced to its local day.
DateTime? jsonDate(Object? value) {
  if (value is! String) return null;
  final text = value.trim();
  final day = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(text);
  if (day != null) {
    return DateTime(int.parse(day[1]!), int.parse(day[2]!), int.parse(day[3]!));
  }
  final parsed = DateTime.tryParse(text)?.toLocal();
  return parsed == null
      ? null
      : DateTime(parsed.year, parsed.month, parsed.day);
}

/// A timestamp in local time.
DateTime? jsonDateTime(Object? value) =>
    value is String ? DateTime.tryParse(value.trim())?.toLocal() : null;

/// The objects in a list, skipping anything that is not an object.
List<Map<String, dynamic>> jsonMaps(Object? value) => value is List
    ? [
        for (final entry in value.whereType<Map>())
          Map<String, dynamic>.from(entry),
      ]
    : const [];

/// An object, or null.
Map<String, dynamic>? jsonMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

/// Unwraps a Laravel resource `{"data": ...}` when present.
Object? unwrapData(Object? raw) =>
    raw is Map && raw.length <= 3 && raw.containsKey('data')
        ? raw['data']
        : raw;
