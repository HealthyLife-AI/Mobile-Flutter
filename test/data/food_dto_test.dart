import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/models/food_dto.dart';

/// A food object as the server sends it (API guide 5.2).
Map<String, dynamic> _food({
  Object? id = 3,
  Object? nameAr = 'كبسة دجاج',
  Object? nameEn = 'Chicken kabsa',
  Object? calories = 165,
  Object? protein = 10,
  Object? carbs = 18,
  Object? fat = 6,
  Object? allergens = const ['tree_nuts'],
  Object? section = 'meat_poultry_fish',
}) =>
    {
      'id': id,
      'name_en': nameEn,
      'name_ar': nameAr,
      'source': 'admin',
      'status': 'approved',
      'calories_per_100g': calories,
      'protein_g_per_100g': protein,
      'carbs_g_per_100g': carbs,
      'fat_g_per_100g': fat,
      'fiber_g_per_100g': null,
      'allergens': allergens,
      'shopping_section': section,
    };

void main() {
  test('maps the server object to a food the app can show and log', () {
    final food = FoodDto.fromJson(_food())!.toEntity();

    expect(food.id, 3);
    expect(food.name, 'كبسة دجاج');
    expect(food.caloriesPer100g, 165);
    expect(food.allergens, ['tree_nuts']);
    expect(food.category, 'cookedProtein');
    // 18 g of carbs per 100 g beats 10 g of protein and 6 g of fat.
    expect(food.macro, 'carbs');
  });

  test('the Arabic name is shown, and the English one is the fallback', () {
    expect(FoodDto.fromJson(_food(nameAr: null))!.name, 'Chicken kabsa');
    expect(FoodDto.fromJson(_food(nameAr: '   '))!.name, 'Chicken kabsa');
  });

  test('a food with no name at all is skipped', () {
    expect(FoodDto.fromJson(_food(nameAr: null, nameEn: ' ')), isNull);
  });

  test('a food without an id is skipped, because a log needs one', () {
    expect(FoodDto.fromJson(_food(id: null)), isNull);
    expect(FoodDto.fromJson(_food(id: 'abc')), isNull);
  });

  test('the macro badge is the macro with the most grams per 100 g', () {
    String macroOf({num protein = 0, num carbs = 0, num fat = 0}) =>
        FoodDto.fromJson(_food(protein: protein, carbs: carbs, fat: fat))!
            .toEntity()
            .macro;

    expect(macroOf(protein: 25, carbs: 5, fat: 2), 'protein');
    expect(macroOf(protein: 2, carbs: 5, fat: 30), 'fat');
    expect(macroOf(protein: 2, carbs: 40, fat: 30), 'carbs');
    expect(macroOf(), 'default');
  });

  test('the tag category comes from the shopping section', () {
    String categoryOf(String? section) =>
        FoodDto.fromJson(_food(section: section))!.toEntity().category;

    expect(categoryOf('produce'), 'greenFruit');
    expect(categoryOf('dairy_eggs'), 'dairy');
    expect(categoryOf('grains_starches'), 'carb');
    expect(categoryOf('legumes_nuts'), 'nuts');
    expect(categoryOf('oils_spices'), 'default');
    expect(categoryOf('something_new'), 'default');
    expect(categoryOf(null), 'default');
  });

  test('only text allergens are kept, and a non-list means none', () {
    expect(
      FoodDto.fromJson(_food(allergens: ['egg', 3, null, 'fish']))!.allergens,
      ['egg', 'fish'],
    );
    expect(FoodDto.fromJson(_food(allergens: 'egg'))!.allergens, isEmpty);
  });

  test('the calories are rounded to a whole number', () {
    expect(
      FoodDto.fromJson(_food(calories: 165.6))!.toEntity().caloriesPer100g,
      166,
    );
  });
}
