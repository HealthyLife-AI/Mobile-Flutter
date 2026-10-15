import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/models/review_dto.dart';
import 'package:healthylife_ai/domain/entities/review_entities.dart';

/// A note as the server sends it (API guide 9.2).
Map<String, dynamic> _review({
  Object? id = 12,
  Object? rating = 'small_adjustment',
  Object? note = 'Drink more water.',
  Object? keyPoints = const ['Water', 'Sleep'],
  Object? tasks = const [
    {'id': 40, 'title': 'Drink 8 cups of water a day', 'done_at': null},
  ],
  Object? createdAt = '2026-10-06T12:00:00+00:00',
  Object? acknowledgedAt,
  Object? editedAt,
}) =>
    {
      'id': id,
      'rating': rating,
      'note': note,
      'key_points': keyPoints,
      'tasks': tasks,
      'acknowledged_at': acknowledgedAt,
      'edited_at': editedAt,
      'created_at': createdAt,
    };

void main() {
  test('maps the note, its tasks and its dates', () {
    final review = ReviewDto.fromJson(_review(
      acknowledgedAt: '2026-10-07T08:00:00+00:00',
      editedAt: '2026-10-08T09:00:00+00:00',
    ))!;

    expect(review.id, 12);
    expect(review.rating, ReviewRating.smallAdjustment);
    expect(review.note, 'Drink more water.');
    expect(review.keyPoints, ['Water', 'Sleep']);
    expect(review.tasks.single.id, 40);
    expect(review.tasks.single.isDone, isFalse);
    expect(review.createdAt?.toUtc(), DateTime.utc(2026, 10, 6, 12));
    expect(review.isAcknowledged, isTrue);
    expect(review.editedAt?.toUtc(), DateTime.utc(2026, 10, 8, 9));
  });

  test('each rating value has its own entry, and anything else is none', () {
    ReviewRating ratingOf(Object? value) =>
        ReviewDto.fromJson(_review(rating: value))!.rating;

    expect(ratingOf('on_track'), ReviewRating.onTrack);
    expect(ratingOf('small_adjustment'), ReviewRating.smallAdjustment);
    expect(ratingOf('review_together'), ReviewRating.reviewTogether);
    expect(ratingOf(null), ReviewRating.none);
    expect(ratingOf('something_new'), ReviewRating.none);
  });

  test('a note without an id is skipped, because it cannot be acknowledged',
      () {
    expect(ReviewDto.fromJson(_review(id: null)), isNull);
    expect(ReviewDto.fromJson(_review(id: 'abc')), isNull);
  });

  test('a task is done when it has a done time', () {
    final review = ReviewDto.fromJson(_review(tasks: [
      {'id': 41, 'title': 'Walk', 'done_at': '2026-10-06T18:00:00+00:00'},
    ]))!;

    expect(review.tasks.single.isDone, isTrue);
    expect(review.tasks.single.doneAt?.toUtc(), DateTime.utc(2026, 10, 6, 18));
  });

  test('tasks without an id or a title are dropped', () {
    final review = ReviewDto.fromJson(_review(tasks: [
      {'id': 40, 'title': 'Keep', 'done_at': null},
      {'title': 'No id', 'done_at': null},
      {'id': 42, 'title': '  ', 'done_at': null},
      'not a task',
    ]))!;

    expect(review.tasks.map((task) => task.title), ['Keep']);
  });

  test('key points keep only non-blank text', () {
    final review = ReviewDto.fromJson(_review(
      keyPoints: ['Water', '  ', 7, null, ' Sleep '],
    ))!;

    expect(review.keyPoints, ['Water', 'Sleep']);
  });

  test('a missing note is empty, and a missing or unreadable date is null', () {
    final review = ReviewDto.fromJson(_review(
      note: null,
      createdAt: 'not a date',
    ))!;

    expect(review.note, isEmpty);
    expect(review.createdAt, isNull);
    expect(review.acknowledgedAt, isNull);
    expect(review.editedAt, isNull);
    expect(review.isAcknowledged, isFalse);
  });
}
