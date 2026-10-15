import '../../domain/entities/notification_entities.dart';

/// One inbox row from `GET /me/notifications` (API guide 10.2):
/// `{id, category, type, title, body, data, read_at, created_at, updated_at}`.
///
/// The title and body are shown as the server wrote them, in the language the
/// patient had when the row was created (10.2).
abstract final class NotificationDto {
  /// Null for a row without an id, which can be neither shown nor marked read.
  static NotificationEntry? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! num && id is! String) return null;
    final category = switch (json['category']) {
      'meals' => NotificationCategory.meals,
      'measurements' => NotificationCategory.measurements,
      'nutritionist' => NotificationCategory.nutritionist,
      'plan' => NotificationCategory.planUpdates,
      _ => NotificationCategory.other, // system, or a new category
    };
    final data = json['data'];
    final reviewId = data is Map ? data['review_id'] : null;
    // A row is "updated" when a repeat event refreshed it (10.3); the newer
    // time is the one the patient should see.
    final at = _time(json['updated_at']) ?? _time(json['created_at']);
    return NotificationEntry(
      id: '$id',
      category: category,
      variant: NotificationVariant.plain,
      title: _text(json['title']) ?? '',
      body: _text(json['body']) ?? '',
      time: '',
      emoji: _emoji(category),
      unread: json['read_at'] == null,
      createdAt: at,
      type: _text(json['type']),
      reviewId: reviewId == null ? null : '$reviewId',
    );
  }

  static String _emoji(NotificationCategory category) => switch (category) {
        NotificationCategory.meals => '🍽️',
        NotificationCategory.measurements => '⚖️',
        NotificationCategory.planUpdates => '📋',
        NotificationCategory.nutritionist => '🩺',
        _ => '🔔',
      };

  static DateTime? _time(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
