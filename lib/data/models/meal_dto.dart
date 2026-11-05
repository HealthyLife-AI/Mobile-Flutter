import '../../domain/entities/meal_entities.dart';

/// Wire-format DTOs for meal-plan / food-search payloads.
///
/// The app currently runs on mock data sources, but every repository entry
/// point goes through these DTOs so swapping in a real HTTP data source is
/// a drop-in change: parse `fromJson`, map `toEntity()`, done. JSON shapes
/// mirror the "Mobile API Reference" (meal-plan §3.1, foods §3.2).
class MealItemDto {
  const MealItemDto(
      {required this.name, required this.grams, required this.checked});

  final String name;
  final int grams;
  final bool checked;

  factory MealItemDto.fromJson(Map<String, dynamic> json) => MealItemDto(
        name: json['name'] as String? ?? '',
        grams: (json['grams'] as num?)?.toInt() ?? 0,
        checked: json['checked'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() =>
      {'name': name, 'grams': grams, 'checked': checked};

  MealItem toEntity() => MealItem(name: name, grams: grams, checked: checked);

  factory MealItemDto.fromEntity(MealItem e) =>
      MealItemDto(name: e.name, grams: e.grams, checked: e.checked);
}

class MealDto {
  const MealDto({
    required this.id,
    required this.name,
    required this.timeRange,
    required this.calories,
    required this.items,
    required this.alternativesText,
    required this.status,
    required this.iconEmojiSlot,
  });

  final String id;
  final String name;
  final String timeRange;
  final int calories;
  final List<MealItemDto> items;
  final String alternativesText;
  final String status;
  final String iconEmojiSlot;

  factory MealDto.fromJson(Map<String, dynamic> json) => MealDto(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        timeRange: json['timeRange'] as String? ?? '',
        calories: (json['calories'] as num?)?.toInt() ?? 0,
        items: (json['items'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(MealItemDto.fromJson)
            .toList(),
        alternativesText: json['alternativesText'] as String? ?? '',
        status: json['status'] as String? ?? 'upcoming',
        iconEmojiSlot: json['iconEmojiSlot'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'timeRange': timeRange,
        'calories': calories,
        'items': items.map((i) => i.toJson()).toList(),
        'alternativesText': alternativesText,
        'status': status,
        'iconEmojiSlot': iconEmojiSlot,
      };

  Meal toEntity() => Meal(
        id: id,
        name: name,
        timeRange: timeRange,
        calories: calories,
        items: items.map((i) => i.toEntity()).toList(),
        alternativesText: alternativesText,
        status: switch (status) {
          'logged' => MealStatus.logged,
          'current' => MealStatus.current,
          _ => MealStatus.upcoming,
        },
        iconEmojiSlot: iconEmojiSlot,
      );

  factory MealDto.fromEntity(Meal e) => MealDto(
        id: e.id,
        name: e.name,
        timeRange: e.timeRange,
        calories: e.calories,
        items: e.items.map(MealItemDto.fromEntity).toList(),
        alternativesText: e.alternativesText,
        status: e.status.name,
        iconEmojiSlot: e.iconEmojiSlot,
      );
}

class FoodOptionDto {
  const FoodOptionDto({
    required this.name,
    required this.grams,
    required this.calories,
    required this.macroLabel,
    required this.isOriginal,
    required this.selected,
    required this.locked,
  });

  final String name;
  final int grams;
  final int calories;
  final String macroLabel;
  final bool isOriginal;
  final bool selected;
  final bool locked;

  factory FoodOptionDto.fromJson(Map<String, dynamic> json) => FoodOptionDto(
        name: json['name'] as String? ?? '',
        grams: (json['grams'] as num?)?.toInt() ?? 0,
        calories: (json['calories'] as num?)?.toInt() ?? 0,
        macroLabel: json['macroLabel'] as String? ?? '',
        isOriginal: json['isOriginal'] as bool? ?? false,
        selected: json['selected'] as bool? ?? false,
        locked: json['locked'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'grams': grams,
        'calories': calories,
        'macroLabel': macroLabel,
        'isOriginal': isOriginal,
        'selected': selected,
        'locked': locked,
      };

  FoodOption toEntity() => FoodOption(
        name: name,
        grams: grams,
        calories: calories,
        macroLabel: macroLabel,
        isOriginal: isOriginal,
        selected: selected,
        locked: locked,
      );

  factory FoodOptionDto.fromEntity(FoodOption e) => FoodOptionDto(
        name: e.name,
        grams: e.grams,
        calories: e.calories,
        macroLabel: e.macroLabel,
        isOriginal: e.isOriginal,
        selected: e.selected,
        locked: e.locked,
      );
}

class FoodCategoryGroupDto {
  const FoodCategoryGroupDto({required this.title, required this.options});

  final String title;
  final List<FoodOptionDto> options;

  factory FoodCategoryGroupDto.fromJson(Map<String, dynamic> json) =>
      FoodCategoryGroupDto(
        title: json['title'] as String? ?? '',
        options: (json['options'] as List<dynamic>? ?? [])
            .whereType<Map<String, dynamic>>()
            .map(FoodOptionDto.fromJson)
            .toList(),
      );

  Map<String, dynamic> toJson() =>
      {'title': title, 'options': options.map((o) => o.toJson()).toList()};

  FoodCategoryGroup toEntity() => FoodCategoryGroup(
      title: title, options: options.map((o) => o.toEntity()).toList());

  factory FoodCategoryGroupDto.fromEntity(FoodCategoryGroup e) =>
      FoodCategoryGroupDto(
          title: e.title,
          options: e.options.map(FoodOptionDto.fromEntity).toList());
}
