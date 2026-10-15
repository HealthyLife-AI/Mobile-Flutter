import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../core/sync/offline_queue.dart';
import '../../core/time/date_only.dart';
import '../../core/utils/uuid_v4.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../domain/repositories/meal_log_repository.dart';
import '../models/meal_log_entry_dto.dart';

/// Storage-backed meal log. The in-memory cache is the source of truth for
/// the running session; storage write-through makes logs survive restarts.
///
/// Every food the server knows is also sent to `POST /me/meal-logs` (6.1)
/// through the offline queue (14), so it reaches the server even if the patient
/// is offline when they log it: off-plan foods with a server id, and each item
/// of a meal from the server's plan with its `meal_item_id`. That is what lets
/// the nutritionist see the patient's adherence.
class MealLogRepositoryImpl implements MealLogRepository, PatientCache {
  MealLogRepositoryImpl(
    this._storage,
    this._queue, {
    DateTime Function()? clock,
    String Function()? newKey,
  })  : _clock = clock ?? DateTime.now,
        _newKey = newKey ?? newUuidV4;

  static const String _path = 'me/meal-logs';

  final StorageService _storage;
  final OfflineQueue _queue;
  final DateTime Function() _clock;
  final String Function() _newKey;
  List<MealLogEntry>? _cache;

  @override
  Future<Result<List<MealLogEntry>>> getEntries() =>
      guard(() async => List.unmodifiable(await _load()));

  /// Marks a plan meal as eaten. Once per meal per day: logging the same meal
  /// again today returns the entry already kept. A meal logged on another day
  /// is logged again.
  ///
  /// A meal from the server's plan sends one log per food eaten, each with its
  /// own idempotency key, kept for every retry (14.1).
  @override
  Future<Result<MealLogEntry>> logPlanned(Meal meal, {List<PlanItem>? eaten}) =>
      guard(() async {
        final now = _clock();
        final entries = await _load();
        final existing = entries
            .where((e) =>
                e.plannedMeal?.id == meal.id && isSameLocalDay(e.loggedAt, now))
            .firstOrNull;
        if (existing != null) return existing; // idempotent — no duplicates
        final items = eaten ?? meal.source?.items ?? const <PlanItem>[];
        final entry = MealLogEntry(
          id: 'planned-${meal.id}-${dateOnly(now)}',
          name: meal.name,
          calories: items.isEmpty
              ? meal.calories
              : items.fold(0.0, (t, i) => t + i.macros.calories).round(),
          grams: items.isEmpty
              ? meal.items.fold(0, (total, item) => total + item.grams)
              : items.fold(0, (total, item) => total + item.quantityGrams),
          loggedAt: now,
          isOffPlan: false,
          plannedMeal: meal,
        );
        final sends = meal.source == null ? const <PlanItem>[] : items;
        for (final item in sends) {
          await _queue.enqueue(path: _path, body: {
            'food_id': item.food.id,
            // The plan item (or alternative) eaten; the plan meal decides
            // the meal type on the server (6.1).
            'meal_item_id': item.id,
            'quantity_grams': item.quantityGrams,
            'logged_at': now.toUtc().toIso8601String(),
            'idempotency_key': _newKey(),
          });
        }
        await _append(entry);
        if (sends.isNotEmpty) await _queue.flush();
        return entry;
      });

  /// Records an off-plan food. With a server food id the log is queued first,
  /// so it is not lost, then sent now if there is a connection. Its
  /// idempotency key is made here and kept for every retry (14.1).
  @override
  Future<Result<MealLogEntry>> logFood(SearchableFood food,
          {required int grams}) =>
      guard(() async {
        final now = _clock();
        final foodId = food.id;
        final entry = MealLogEntry(
          id: 'food-${now.microsecondsSinceEpoch}',
          name: food.name,
          calories: (food.caloriesPer100g * grams / 100).round(),
          grams: grams,
          loggedAt: now,
          isOffPlan: true,
        );
        if (foodId != null) {
          await _queue.enqueue(path: _path, body: {
            'food_id': foodId,
            'quantity_grams': grams,
            // The real time it was eaten, in UTC with an offset (1.2, 14.1).
            'logged_at': now.toUtc().toIso8601String(),
            'idempotency_key': _newKey(),
          });
        }
        await _append(entry);
        if (foodId != null) await _queue.flush();
        return entry;
      });

  @override
  Future<Result<void>> clear() => guard(() async {
        _cache = [];
        await _storage.remove(StorageKeys.mealLogEntries);
      });

  @override
  Future<void> forgetPatientData() async {
    _cache = null;
    await _storage.remove(StorageKeys.mealLogEntries);
  }

  Future<List<MealLogEntry>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;
    try {
      final raw = await _storage.readMap(StorageKeys.mealLogEntries);
      final list = raw?['entries'];
      _cache = list is List
          ? list
              .whereType<Map<String, dynamic>>()
              .map(MealLogEntryDto.fromJson)
              .map((dto) => dto.toEntity())
              .toList()
          : [];
    } on Object {
      // Corrupt payload: start clean instead of bricking the log screen.
      _cache = [];
    }
    return _cache!;
  }

  Future<void> _append(MealLogEntry entry) async {
    final entries = await _load();
    _cache = [...entries, entry];
    await _persist();
  }

  Future<void> _persist() async {
    final entries = _cache ?? const <MealLogEntry>[];
    await _storage.writeMap(StorageKeys.mealLogEntries, {
      'entries':
          entries.map((e) => MealLogEntryDto.fromEntity(e).toJson()).toList(),
    });
  }
}
