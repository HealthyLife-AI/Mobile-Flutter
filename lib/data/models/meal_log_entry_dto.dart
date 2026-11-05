import '../../domain/entities/meal_entities.dart';
import 'meal_dto.dart';

/// Wire-format persistence for a logged meal entry (local storage today,
/// backend sync later). Planned meals are embedded so the daily log can
/// render them after a restart without refetching the plan.
class MealLogEntryDto {
  const MealLogEntryDto({
    required this.id,
    required this.name,
    required this.calories,
    required this.grams,
    required this.loggedAt,
    required this.isOffPlan,
    this.plannedMeal,
  });

  final String id;
  final String name;
  final int calories;
  final int grams;
  final DateTime loggedAt;
  final bool isOffPlan;
  final MealDto? plannedMeal;

  factory MealLogEntryDto.fromJson(Map<String, dynamic> json) =>
      MealLogEntryDto(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        calories: (json['calories'] as num?)?.toInt() ?? 0,
        grams: (json['grams'] as num?)?.toInt() ?? 0,
        loggedAt: DateTime.tryParse(json['loggedAt'] as String? ?? '') ??
            DateTime.now(),
        isOffPlan: json['isOffPlan'] as bool? ?? false,
        plannedMeal: json['plannedMeal'] is Map<String, dynamic>
            ? MealDto.fromJson(json['plannedMeal'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'grams': grams,
        'loggedAt': loggedAt.toIso8601String(),
        'isOffPlan': isOffPlan,
        if (plannedMeal != null) 'plannedMeal': plannedMeal!.toJson(),
      };

  MealLogEntry toEntity() => MealLogEntry(
        id: id,
        name: name,
        calories: calories,
        grams: grams,
        loggedAt: loggedAt,
        isOffPlan: isOffPlan,
        plannedMeal: plannedMeal?.toEntity(),
      );

  factory MealLogEntryDto.fromEntity(MealLogEntry e) => MealLogEntryDto(
        id: e.id,
        name: e.name,
        calories: e.calories,
        grams: e.grams,
        loggedAt: e.loggedAt,
        isOffPlan: e.isOffPlan,
        plannedMeal:
            e.plannedMeal == null ? null : MealDto.fromEntity(e.plannedMeal!),
      );
}
