import 'entities/review_entities.dart';

/// The notes with the one a push names moved to the top, the rest keeping their
/// order. A null [focusId], or one that is not in [reviews], leaves the list as
/// it is. [focusId] is compared with the note's id as text, because a push
/// carries it as a string.
List<NutritionistReview> reviewsFocusedFirst(
  List<NutritionistReview> reviews,
  String? focusId,
) {
  if (focusId == null) return reviews;
  final index = reviews.indexWhere((review) => '${review.id}' == focusId);
  if (index <= 0) return reviews;
  return [
    reviews[index],
    ...reviews.sublist(0, index),
    ...reviews.sublist(index + 1),
  ];
}
