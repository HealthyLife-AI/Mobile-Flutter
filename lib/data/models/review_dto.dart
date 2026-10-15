import '../../domain/entities/review_entities.dart';

/// One note from `GET /me/reviews` (API guide 9.2). A note without an id is
/// skipped, because the app cannot acknowledge it. A task without an id or a
/// title is skipped too. Everything else is read tolerantly: a missing text is
/// empty, and a missing or unreadable date is null.
class ReviewDto {
  ReviewDto._();

  /// Null when the note has no id.
  static NutritionistReview? fromJson(Map<String, dynamic> json) {
    final id = _int(json['id']);
    if (id == null) return null;
    return NutritionistReview(
      id: id,
      rating: _rating(json['rating']),
      note: _text(json['note']) ?? '',
      keyPoints: _texts(json['key_points']),
      tasks: _tasks(json['tasks']),
      createdAt: _date(json['created_at']),
      acknowledgedAt: _date(json['acknowledged_at']),
      editedAt: _date(json['edited_at']),
    );
  }

  static ReviewRating _rating(Object? value) => switch (value) {
        'on_track' => ReviewRating.onTrack,
        'small_adjustment' => ReviewRating.smallAdjustment,
        'review_together' => ReviewRating.reviewTogether,
        _ => ReviewRating.none,
      };

  static List<ReviewTask> _tasks(Object? value) {
    if (value is! List) return const [];
    return value.map(_task).whereType<ReviewTask>().toList();
  }

  static ReviewTask? _task(Object? value) {
    if (value is! Map) return null;
    final id = _int(value['id']);
    final title = _text(value['title']);
    if (id == null || title == null) return null;
    return ReviewTask(id: id, title: title, doneAt: _date(value['done_at']));
  }

  static List<String> _texts(Object? value) {
    if (value is! List) return const [];
    return value.map(_text).whereType<String>().toList();
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num && value == value.roundToDouble()) return value.toInt();
    return null;
  }

  /// Read as local time, so the day shown is the patient's own day.
  static DateTime? _date(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;
}
