import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/repositories/meal_log_repository.dart';
import '../models/meal_log_entry_dto.dart';

/// Storage-backed meal log. The in-memory cache is the source of truth for
/// the running session; storage write-through makes logs survive restarts.
///
/// Replaces the old `MealLogStore` singleton: one instance is created by
/// the composition root, so tests get a fresh, isolated repository.
class MealLogRepositoryImpl implements MealLogRepository {
  MealLogRepositoryImpl(this._storage);

  final StorageService _storage;
  List<MealLogEntry>? _cache;

  @override
  Future<Result<List<MealLogEntry>>> getEntries() => guard(() async => List.unmodifiable(await _load()));

  @override
  Future<Result<MealLogEntry>> logPlanned(Meal meal) => guard(() async {
        final entries = await _load();
        final existing = entries.where((e) => e.plannedMeal?.id == meal.id).firstOrNull;
        if (existing != null) return existing; // idempotent — no duplicates
        final entry = MealLogEntry(
          id: 'planned-${meal.id}',
          name: meal.name,
          calories: meal.calories,
          grams: meal.items.fold(0, (total, item) => total + item.grams),
          loggedAt: DateTime.now(),
          isOffPlan: false,
          plannedMeal: meal,
        );
        await _append(entry);
        return entry;
      });

  @override
  Future<Result<MealLogEntry>> logFood(SearchableFood food, {required int grams}) => guard(() async {
        final entry = MealLogEntry(
          id: 'food-${DateTime.now().microsecondsSinceEpoch}',
          name: food.name,
          calories: (food.caloriesPer100g * grams / 100).round(),
          grams: grams,
          loggedAt: DateTime.now(),
          isOffPlan: true,
        );
        await _append(entry);
        return entry;
      });

  @override
  Future<Result<void>> clear() => guard(() async {
        _cache = [];
        await _storage.remove(StorageKeys.mealLogEntries);
      });

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
      'entries': entries.map((e) => MealLogEntryDto.fromEntity(e).toJson()).toList(),
    });
  }
}
