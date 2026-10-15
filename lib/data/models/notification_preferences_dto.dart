import '../../domain/entities/notification_preferences.dart';

/// `GET` / `PUT /me/notification-preferences` (API guide 10.5). The request
/// is flat; the response is nested. A missing or wrongly typed field keeps
/// the server's default.
abstract final class NotificationPreferencesDto {
  /// Reads the nested response.
  static NotificationPreferences fromJson(Map<String, dynamic> json) {
    const defaults = NotificationPreferences();
    final categories = json['categories'];
    final quiet = json['quiet_hours'];
    bool flag(Object? map, String key, bool fallback) {
      final value = map is Map ? map[key] : null;
      return value is bool ? value : fallback;
    }

    return NotificationPreferences(
      meals: flag(categories, 'meals', defaults.meals),
      measurements: flag(categories, 'measurements', defaults.measurements),
      nutritionist: flag(categories, 'nutritionist', defaults.nutritionist),
      plan: flag(categories, 'plan', defaults.plan),
      quietHoursEnabled: flag(quiet, 'enabled', defaults.quietHoursEnabled),
      quietStartMinute: _minute(quiet is Map ? quiet['start'] : null) ??
          defaults.quietStartMinute,
      quietEndMinute: _minute(quiet is Map ? quiet['end'] : null) ??
          defaults.quietEndMinute,
    );
  }

  /// The flat request body. `system` cannot be switched off, so it is not
  /// sent.
  static Map<String, dynamic> toRequest(NotificationPreferences p) => {
        'meals': p.meals,
        'measurements': p.measurements,
        'nutritionist': p.nutritionist,
        'plan': p.plan,
        'quiet_hours_enabled': p.quietHoursEnabled,
        'quiet_start': clockText(p.quietStartMinute),
        'quiet_end': clockText(p.quietEndMinute),
      };

  /// The device copy, in the response's nested shape so [fromJson] reads it.
  static Map<String, dynamic> toJson(NotificationPreferences p) => {
        'categories': {
          'meals': p.meals,
          'measurements': p.measurements,
          'nutritionist': p.nutritionist,
          'plan': p.plan,
        },
        'quiet_hours': {
          'enabled': p.quietHoursEnabled,
          'start': clockText(p.quietStartMinute),
          'end': clockText(p.quietEndMinute),
        },
      };

  /// `HH:MM`, 24-hour.
  static String clockText(int minuteOfDay) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(minuteOfDay ~/ 60)}:${two(minuteOfDay % 60)}';
  }

  static int? _minute(Object? value) {
    if (value is! String) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value.trim());
    if (match == null) return null;
    final hour = int.parse(match[1]!);
    final minute = int.parse(match[2]!);
    if (hour > 23 || minute > 59) return null;
    return hour * 60 + minute;
  }
}
