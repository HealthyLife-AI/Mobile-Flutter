import '../../domain/entities/meal_entities.dart';

/// A food object from `GET /foods/search` (API guide 5.2). Only what the app
/// shows and logs is kept. A food without an id is skipped, because a log needs
/// one (6.1). A food without any name is skipped too, because it cannot be shown.
class FoodDto {
  const FoodDto({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    required this.allergens,
    required this.shoppingSection,
    this.fiberGPer100g,
  });

  final int id;

  /// The Arabic name, or the English one when there is no Arabic (guide 5.2).
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final List<String> allergens;
  final String? shoppingSection;

  /// Fibre per 100 g (guide 5.2). Null when the server sends none.
  final double? fiberGPer100g;

  /// Null when the object has no id or no name.
  static FoodDto? fromJson(Map<String, dynamic> json) {
    final id = _int(json['id']);
    final name = _text(json['name_ar']) ?? _text(json['name_en']);
    if (id == null || name == null) return null;
    final allergens = json['allergens'];
    return FoodDto(
      id: id,
      name: name,
      caloriesPer100g: _number(json['calories_per_100g']),
      proteinPer100g: _number(json['protein_g_per_100g']),
      carbsPer100g: _number(json['carbs_g_per_100g']),
      fatPer100g: _number(json['fat_g_per_100g']),
      allergens:
          allergens is List ? allergens.whereType<String>().toList() : const [],
      shoppingSection: _text(json['shopping_section']),
      fiberGPer100g: _optionalNumber(json['fiber_g_per_100g']),
    );
  }

  SearchableFood toEntity() => SearchableFood(
        id: id,
        name: name,
        caloriesPer100g: caloriesPer100g.round(),
        macro: _dominantMacro(),
        category: _categoryFor(shoppingSection),
        allergens: allergens,
        fiberGPer100g: fiberGPer100g,
      );

  /// The macro badge is the macro with the most grams per 100 g. The server
  /// sends no label, so the app chooses one (see the report's known limits).
  String _dominantMacro() {
    if (proteinPer100g <= 0 && carbsPer100g <= 0 && fatPer100g <= 0) {
      return 'default';
    }
    if (proteinPer100g >= carbsPer100g && proteinPer100g >= fatPer100g) {
      return 'protein';
    }
    if (carbsPer100g >= fatPer100g) return 'carbs';
    return 'fat';
  }

  /// The tag colour and filter group, from the shopping section. The server
  /// has no red-fruit or natural-sugar tag, so neither can come from here.
  static String _categoryFor(String? section) => switch (section) {
        'produce' => 'greenFruit',
        'meat_poultry_fish' => 'cookedProtein',
        'dairy_eggs' => 'dairy',
        'grains_starches' => 'carb',
        'legumes_nuts' => 'nuts',
        _ => 'default',
      };

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num && value == value.roundToDouble()) return value.toInt();
    return null;
  }

  static double _number(Object? value) => value is num ? value.toDouble() : 0.0;

  /// The value as a double, or null when it is missing or not a number.
  static double? _optionalNumber(Object? value) =>
      value is num ? value.toDouble() : null;

  /// The text with its spaces trimmed, or null when it is missing or blank.
  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
