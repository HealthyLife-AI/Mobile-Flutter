import 'entities/meal_entities.dart';

/// True when a food may contain one of the patient's approved allergies (API
/// guide 5.3). [approvedGroups] are the allergy groups the patient has approved.
/// The group `other` has no food tags, so it never matches.
bool mayContainAllergen(SearchableFood food, Set<String> approvedGroups) =>
    food.allergens
        .any((group) => group != 'other' && approvedGroups.contains(group));
