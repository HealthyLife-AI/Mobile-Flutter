/// The nutritionist's notes and the tasks in them (API guide 9.2). Pure Dart.
library;

/// The rating the nutritionist gave a note. `none` when there is no rating.
enum ReviewRating { onTrack, smallAdjustment, reviewTogether, none }

/// A task from a note. The patient ticks it off.
class ReviewTask {
  const ReviewTask({required this.id, required this.title, this.doneAt});

  final int id;
  final String title;

  /// Set while the task is done. Null when it is not.
  final DateTime? doneAt;

  bool get isDone => doneAt != null;
}

/// One note from the nutritionist.
class NutritionistReview {
  const NutritionistReview({
    required this.id,
    required this.rating,
    required this.note,
    required this.keyPoints,
    required this.tasks,
    this.createdAt,
    this.acknowledgedAt,
    this.editedAt,
  });

  final int id;
  final ReviewRating rating;
  final String note;
  final List<String> keyPoints;
  final List<ReviewTask> tasks;
  final DateTime? createdAt;

  /// Set when the patient pressed «فهمت». The server clears it again when the
  /// nutritionist edits the note, and then the button shows again.
  final DateTime? acknowledgedAt;

  /// Set when the nutritionist last edited the note.
  final DateTime? editedAt;

  bool get isAcknowledged => acknowledgedAt != null;
}
