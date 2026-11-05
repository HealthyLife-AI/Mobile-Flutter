import '../../core/time/date_only.dart';
import '../../domain/entities/meal_entities.dart';
import '../models/server_meal_log.dart';

/// Two times this close are the same log: the app sends the time it shows,
/// and the server may drop the milliseconds.
const Duration _sameMoment = Duration(seconds: 2);

/// Brings the device's meal log in line with the server's logs (API guide
/// 6.2). Pure, so the rules are tested on their own.
///
/// * On [day], a saved log the server no longer has (deleted on another
///   device) leaves its entry, and an entry left with nothing saved and
///   nothing waiting in [waitingKeys] goes.
/// * A log no entry knows joins, in this order: an entry made at the same
///   moment that has no server id for it (one from before ids were kept, or
///   whose answer was lost); the entry of the plan meal its `meal_item_id`
///   belongs to, among [planMeals]; or an entry of its own.
///
/// [logs] may cover the days around [day] too, so that a log near midnight is
/// never taken for deleted; only [day]'s entries are checked for deletions.
List<MealLogEntry> reconcileMealLogs({
  required List<MealLogEntry> entries,
  required DateTime day,
  required List<ServerMealLog> logs,
  required Set<String> waitingKeys,
  List<Meal> planMeals = const [],
}) {
  final byId = {for (final log in logs) log.id: log};
  final known = {
    for (final entry in entries)
      for (final sent in entry.sentLogs)
        if (sent.serverId != null) sent.serverId!,
  };

  final result = <MealLogEntry>[];
  for (final entry in entries) {
    if (!isSameLocalDay(entry.loggedAt, day) || entry.sentLogs.isEmpty) {
      result.add(entry);
      continue;
    }
    final kept = [
      for (final sent in entry.sentLogs)
        if (sent.serverId == null)
          sent
        else if (byId[sent.serverId] case final log?)
          SentMealLog(
            key: sent.key,
            serverId: sent.serverId,
            editableUntil: log.editableUntil ?? sent.editableUntil,
          ),
    ];
    final hadSaved = entry.sentLogs.any((sent) => sent.serverId != null);
    final stillThere = kept
        .any((sent) => sent.serverId != null || waitingKeys.contains(sent.key));
    if (hadSaved && !stillThere) continue;
    result.add(entry.copyWith(sentLogs: kept));
  }

  // Entries from before ids were kept take every log of their moment.
  final adopting = <String>{};
  final unknown = [
    for (final log in logs)
      if (!known.contains(log.id)) log,
  ]..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

  for (final log in unknown) {
    final saved = SentMealLog(
      key: 'server-${log.id}',
      serverId: log.id,
      editableUntil: log.editableUntil,
    );

    final same = result.indexWhere((entry) =>
        entry.loggedAt.difference(log.loggedAt).abs() < _sameMoment &&
        (entry.sentLogs.isEmpty ||
            adopting.contains(entry.id) ||
            _openSlot(entry, waitingKeys) != null));
    if (same >= 0) {
      final entry = result[same];
      final slot = _openSlot(entry, waitingKeys);
      if (slot == null) {
        adopting.add(entry.id);
        result[same] = entry.copyWith(sentLogs: [...entry.sentLogs, saved]);
      } else {
        result[same] = entry.copyWith(sentLogs: [
          for (final sent in entry.sentLogs)
            identical(sent, slot)
                ? SentMealLog(
                    key: sent.key,
                    serverId: log.id,
                    editableUntil: log.editableUntil)
                : sent,
        ]);
      }
      continue;
    }

    final meal = _planMealOf(log, planMeals);
    if (meal != null) {
      final own = result.indexWhere((entry) =>
          entry.plannedMeal?.id == meal.id &&
          isSameLocalDay(entry.loggedAt, log.loggedAt));
      if (own >= 0) {
        final entry = result[own];
        result[own] = entry.copyWith(
          calories: entry.calories + log.calories.round(),
          grams: entry.grams + log.grams,
          sentLogs: [...entry.sentLogs, saved],
        );
      } else {
        result.add(MealLogEntry(
          id: 'planned-${meal.id}-${dateOnly(log.loggedAt)}',
          name: meal.name,
          calories: log.calories.round(),
          grams: log.grams,
          loggedAt: log.loggedAt,
          isOffPlan: false,
          plannedMeal: meal,
          sentLogs: [saved],
        ));
      }
      continue;
    }

    result.add(MealLogEntry(
      id: 'server-${log.id}',
      name: log.foodName,
      calories: log.calories.round(),
      grams: log.grams,
      loggedAt: log.loggedAt,
      isOffPlan: log.isOffPlan,
      sentLogs: [saved],
    ));
  }
  return result;
}

/// A log of [entry] with no server id that is not waiting to be sent: its
/// answer was lost, so a server log of the same moment is this one.
SentMealLog? _openSlot(MealLogEntry entry, Set<String> waitingKeys) {
  for (final sent in entry.sentLogs) {
    if (sent.serverId == null && !waitingKeys.contains(sent.key)) return sent;
  }
  return null;
}

/// The plan meal whose items or alternatives include the log's item.
Meal? _planMealOf(ServerMealLog log, List<Meal> planMeals) {
  final itemId = log.mealItemId;
  if (itemId == null) return null;
  for (final meal in planMeals) {
    final items = meal.source?.items ?? const [];
    if (items.any((item) =>
        item.id == itemId ||
        item.alternatives.any((alternative) => alternative.id == itemId))) {
      return meal;
    }
  }
  return null;
}
