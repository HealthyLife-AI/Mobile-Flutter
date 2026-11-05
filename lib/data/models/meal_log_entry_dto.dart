import '../../domain/entities/meal_entities.dart';
import 'meal_dto.dart';

<<<<<<< HEAD
/// Wire-format persistence for a logged meal entry (local storage). Planned
/// meals are embedded so the daily log can render them after a restart
/// without refetching the plan. The logs sent to the server are kept too, so
/// the entry can be deleted there (API guide 6.4).
=======
/// Wire-format persistence for a logged meal entry (local storage today,
/// backend sync later). Planned meals are embedded so the daily log can
/// render them after a restart without refetching the plan.
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
class MealLogEntryDto {
  const MealLogEntryDto({
    required this.id,
    required this.name,
    required this.calories,
    required this.grams,
    required this.loggedAt,
    required this.isOffPlan,
    this.plannedMeal,
<<<<<<< HEAD
    this.sentLogs = const [],
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
  });

  final String id;
  final String name;
  final int calories;
  final int grams;
  final DateTime loggedAt;
  final bool isOffPlan;
  final MealDto? plannedMeal;
<<<<<<< HEAD
  final List<SentMealLog> sentLogs;
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a

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
<<<<<<< HEAD
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
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'grams': grams,
        'loggedAt': loggedAt.toIso8601String(),
        'isOffPlan': isOffPlan,
        if (plannedMeal != null) 'plannedMeal': plannedMeal!.toJson(),
<<<<<<< HEAD
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
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
      };

  MealLogEntry toEntity() => MealLogEntry(
        id: id,
        name: name,
        calories: calories,
        grams: grams,
        loggedAt: loggedAt,
        isOffPlan: isOffPlan,
        plannedMeal: plannedMeal?.toEntity(),
<<<<<<< HEAD
        sentLogs: sentLogs,
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
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
<<<<<<< HEAD
        sentLogs: e.sentLogs,
=======
>>>>>>> 80d1dd472531cb331f5eb32effd9a02afec5507a
      );
}
