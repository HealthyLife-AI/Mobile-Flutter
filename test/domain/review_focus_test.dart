import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/domain/entities/review_entities.dart';
import 'package:healthylife_ai/domain/review_focus.dart';

NutritionistReview _review(int id) => NutritionistReview(
      id: id,
      rating: ReviewRating.none,
      note: 'note $id',
      keyPoints: const [],
      tasks: const [],
    );

void main() {
  final reviews = [_review(1), _review(2), _review(3)];

  List<int> idsOf(List<NutritionistReview> list) =>
      list.map((review) => review.id).toList();

  group('reviewsFocusedFirst', () {
    test('no focus id keeps the order', () {
      expect(idsOf(reviewsFocusedFirst(reviews, null)), [1, 2, 3]);
    });

    test('the named note moves to the top and the rest keep their order', () {
      expect(idsOf(reviewsFocusedFirst(reviews, '3')), [3, 1, 2]);
    });

    test('an id that is not in the list keeps the order', () {
      expect(idsOf(reviewsFocusedFirst(reviews, '9')), [1, 2, 3]);
    });

    test('a note already at the top stays there', () {
      expect(idsOf(reviewsFocusedFirst(reviews, '1')), [1, 2, 3]);
    });
  });
}
