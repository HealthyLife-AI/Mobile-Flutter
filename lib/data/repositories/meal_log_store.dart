import 'package:flutter/material.dart';

import '../../domain/entities/meal_entities.dart';

/// In-memory meal-log store.
///
/// NOTE: transitional. Being replaced by `MealLogRepository` +
/// `MealLogCubit` (with storage persistence); kept here so existing
/// screens keep compiling while the migration lands.

class MealLogStore extends ChangeNotifier {
  MealLogStore._();

  static final MealLogStore instance = MealLogStore._();
  final List<MealLogEntry> _entries = [];

  List<MealLogEntry> get entries => List.unmodifiable(_entries);

  MealLogEntry recordPlanned(Meal meal) {
    for (final entry in _entries) {
      if (entry.plannedMeal?.id == meal.id) return entry;
    }
    final entry = MealLogEntry(
      id: 'planned-${meal.id}',
      name: meal.name,
      calories: meal.calories,
      grams: meal.items.fold(0, (total, item) => total + item.grams),
      loggedAt: DateTime.now(),
      isOffPlan: false,
      plannedMeal: meal,
    );
    _entries.add(entry);
    notifyListeners();
    return entry;
  }

  MealLogEntry recordFood(SearchableFood food, int grams) {
    final entry = MealLogEntry(
      id: 'food-${DateTime.now().microsecondsSinceEpoch}',
      name: food.name,
      calories: (food.caloriesPer100g * grams / 100).round(),
      grams: grams,
      loggedAt: DateTime.now(),
      isOffPlan: true,
    );
    _entries.add(entry);
    notifyListeners();
    return entry;
  }
}

