import '../../domain/entities/meal_entities.dart';
import 'meal_dto.dart';

/// Wire-format persistence for a logged meal entry (local storage). Planned
/// meals are embedded so the daily log can render them after a restart
/// without refetching the plan. The logs sent to the server are kept too, so
/// the entry can be deleted there (API guide 6.4).
class MealLogEntryDto {
  const MealLogEntryDto({
    required this.id,
    required this.name,
    required this.calories,
    required this.grams,
    required this.loggedAt,
    required this.isOffPlan,
    this.plannedMeal,
    this.sentLogs = const [],
  });

  final String id;
  final String name;
  final int calories;
  final int grams;
  final DateTime loggedAt;
  final bool isOffPlan;
  final MealDto? plannedMeal;
  final List<SentMealLog> sentLogs;

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
        sentLogs: [
          if (json['sentLogs'] case final List<dynamic> logs)
            for (final log in logs)
              if (log case {'key': final String key})
                SentMealLog(
                  key: key,
                  serverId: (log['id'] as num?)?.toInt(),
                  editableUntil:
                      DateTime.tryParse(log['editableUntil'] as String? ?? ''),
                ),
        ],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'grams': grams,
        'loggedAt': loggedAt.toIso8601String(),
        'isOffPlan': isOffPlan,
        if (plannedMeal != null) 'plannedMeal': plannedMeal!.toJson(),
        if (sentLogs.isNotEmpty)
          'sentLogs': [
            for (final log in sentLogs)
              {
                'key': log.key,
                if (log.serverId != null) 'id': log.serverId,
                if (log.editableUntil != null)
                  'editableUntil': log.editableUntil!.toIso8601String(),
              },
          ],
      };

  MealLogEntry toEntity() => MealLogEntry(
        id: id,
        name: name,
        calories: calories,
        grams: grams,
        loggedAt: loggedAt,
        isOffPlan: isOffPlan,
        plannedMeal: plannedMeal?.toEntity(),
        sentLogs: sentLogs,
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
        sentLogs: e.sentLogs,
      );
}
