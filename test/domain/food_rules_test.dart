import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/domain/entities/meal_entities.dart';
import 'package:healthylife_ai/domain/food_rules.dart';

void main() {
  const almonds = SearchableFood(
    name: 'لوز',
    caloriesPer100g: 579,
    macro: 'fat',
    allergens: ['tree_nuts'],
  );
  const rice =
      SearchableFood(name: 'أرز', caloriesPer100g: 130, macro: 'carbs');
  const milk = SearchableFood(
    name: 'حليب',
    caloriesPer100g: 60,
    macro: 'protein',
    allergens: ['milk_lactose', 'egg'],
  );

  test('a food is flagged when it shares an approved group', () {
    expect(mayContainAllergen(almonds, {'tree_nuts'}), isTrue);
    expect(mayContainAllergen(milk, {'egg'}), isTrue);
  });

  test('a food is not flagged without a shared group', () {
    expect(mayContainAllergen(almonds, {'peanuts'}), isFalse);
    expect(mayContainAllergen(rice, {'tree_nuts'}), isFalse);
  });

  test('no approved allergies flags nothing', () {
    expect(mayContainAllergen(almonds, <String>{}), isFalse);
  });

  test('the other group never matches, because foods carry no such tag', () {
    const food = SearchableFood(
      name: 'x',
      caloriesPer100g: 1,
      macro: 'default',
      allergens: ['other'],
    );
    expect(mayContainAllergen(food, {'other'}), isFalse);
  });
}
