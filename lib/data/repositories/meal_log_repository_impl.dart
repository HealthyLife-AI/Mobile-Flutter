import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../core/sync/offline_queue.dart';
import '../../core/sync/pending_write.dart';
import '../../core/time/date_only.dart';
import '../../core/utils/uuid_v4.dart';
import '../../domain/entities/meal_entities.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../domain/repositories/meal_log_repository.dart';
import '../models/json_read.dart';
import '../models/meal_log_entry_dto.dart';
import '../models/server_meal_log.dart';
import 'meal_log_sync.dart';

/// Storage-backed meal log. The in-memory cache is the source of truth for
/// the running session; storage write-through makes logs survive restarts.
///
/// Every food the server knows is also sent to `POST /me/meal-logs` (6.1)
/// through the offline queue (14), so it reaches the server even if the patient
/// is offline when they log it: off-plan foods with a server id, and each item
/// of a meal from the server's plan with its `meal_item_id`. That is what lets
/// the nutritionist see the patient's adherence.
///
/// Each entry keeps the idempotency keys of its logs, and the queue reports
/// the server's id for each one it saves ([recordSaved]), so deleting an entry
/// also deletes its logs on the server (6.4).
class MealLogRepositoryImpl implements MealLogRepository, PatientCache {
  MealLogRepositoryImpl(
    this._storage,
    this._queue,
    this._api, {
    DateTime Function()? clock,
    String Function()? newKey,
  })  : _clock = clock ?? DateTime.now,
        _newKey = newKey ?? newUuidV4;

  static const String _path = 'me/meal-logs';

  /// 15 logs a page (6.2): three days of meals fit well inside this.
  static const int _maxPages = 10;

  final StorageService _storage;
  final OfflineQueue _queue;
  final ApiClient _api;
  final DateTime Function() _clock;
  final String Function() _newKey;
  List<MealLogEntry>? _cache;

  /// The changes to the entries, one after another, so two changes never
  /// overwrite each other.
  Future<void> _changes = Future<void>.value();

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
        final sends = meal.source == null ? const <PlanItem>[] : items;
        final bodies = [
          for (final item in sends)
            {
              'food_id': item.food.id,
              // The plan item (or alternative) eaten; the plan meal decides
              // the meal type on the server (6.1).
              'meal_item_id': item.id,
              'quantity_grams': item.quantityGrams,
              'logged_at': now.toUtc().toIso8601String(),
              'idempotency_key': _newKey(),
            },
        ];
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
          sentLogs: _sentLogsFor(bodies),
        );
        await _keep(entry, bodies);
        return entry;
      });

  /// Records an off-plan food. With a server food id the log is queued, so it
  /// is not lost, then sent now if there is a connection. Its idempotency key
  /// is made here and kept for every retry (14.1).
  @override
  Future<Result<MealLogEntry>> logFood(SearchableFood food,
          {required int grams}) =>
      guard(() async {
        final now = _clock();
        final foodId = food.id;
        final bodies = [
          if (foodId != null)
            {
              'food_id': foodId,
              'quantity_grams': grams,
              // The real time it was eaten, in UTC with an offset (1.2, 14.1).
              'logged_at': now.toUtc().toIso8601String(),
              'idempotency_key': _newKey(),
            },
        ];
        final entry = MealLogEntry(
          id: 'food-${now.microsecondsSinceEpoch}',
          name: food.name,
          calories: (food.caloriesPer100g * grams / 100).round(),
          grams: grams,
          loggedAt: now,
          isOffPlan: true,
          sentLogs: _sentLogsFor(bodies),
        );
        await _keep(entry, bodies);
        return entry;
      });

  @override
  Future<Result<void>> delete(String entryId) => guard(() async {
        // No queued write may be sent while it is taken out (6.4, 14).
        await _queue.paused(() async {
          final entry =
              (await _load()).where((e) => e.id == entryId).firstOrNull;
          if (entry == null) return;

          // Logs that never reached the server leave the queue unsent. A log
          // with no server id that is not queued was refused: there is
          // nothing to delete for it.
          final keys = {for (final log in entry.sentLogs) log.key};
          if (keys.isNotEmpty) {
            await _queue.removeWhere((write) =>
                write.path == _path &&
                keys.contains(write.body['idempotency_key']));
          }

          final saved = [
            for (final log in entry.sentLogs)
              if (log.serverId != null) log,
          ];
          while (saved.isNotEmpty) {
            try {
              await _api.delete('$_path/${saved.first.serverId}');
            } on NotFoundException {
              // The server no longer has it: deleted already.
            } on AppException {
              // Keep the logs not deleted yet, so trying again finishes.
              await _change((entries) => [
                    for (final e in entries)
                      e.id == entryId ? e.copyWith(sentLogs: saved) : e,
                  ]);
              rethrow;
            }
            saved.removeAt(0);
          }
          await _change((entries) => [
                for (final e in entries)
                  if (e.id != entryId) e,
              ]);
        });
      });

  @override
  Future<Result<void>> syncDay(DateTime day,
          {List<Meal> planMeals = const []}) =>
      guard(() async {
        // No queued log may be saved meanwhile: its id would arrive after the
        // list was read, and its entry would look deleted elsewhere.
        await _queue.paused(() async {
          final logs = await _fetchAround(day);
          final waiting = {
            for (final write in await _queue.pendingWrites())
              if (write.path == _path) '${write.body['idempotency_key']}',
          };
          await _change((entries) => reconcileMealLogs(
                entries: entries,
                day: day,
                logs: logs,
                waitingKeys: waiting,
                planMeals: planMeals,
              ));
        });
      }, context: 'MealLogRepository.syncDay');

  @override
  Future<Result<MealLogEntry>> updateGrams(String entryId, int grams) =>
      guard(() async {
        final entry = (await _load()).where((e) => e.id == entryId).firstOrNull;
        final sent = entry?.sentLogs.singleOrNull;
        final serverId = sent?.serverId;
        if (entry == null || sent == null || serverId == null) {
          throw const NotFoundException('No saved log to change');
        }
        final Object? raw;
        try {
          raw = await _api
              .patch('$_path/$serverId', body: {'quantity_grams': grams});
        } on NotFoundException {
          // Deleted on another device: it goes here too.
          await _change((entries) => [
                for (final e in entries)
                  if (e.id != entryId) e,
              ]);
          rethrow;
        }
        final log = ServerMealLog.fromJson(jsonMap(raw) ?? const {});
        if (log == null) {
          throw const ParseException('The changed log could not be read');
        }
        final changed = entry.copyWith(
          grams: log.grams,
          calories: log.calories.round(),
          sentLogs: [
            SentMealLog(
                key: sent.key,
                serverId: log.id,
                editableUntil: log.editableUntil ?? sent.editableUntil),
          ],
        );
        await _change((entries) => [
              for (final e in entries) e.id == entryId ? changed : e,
            ]);
        return changed;
      }, context: 'MealLogRepository.updateGrams');

  /// The logs of [day] and the days on either side. The server counts days
  /// in the clinic's time zone (1.2); the neighbours keep a log near midnight
  /// from looking deleted when the device's zone differs.
  Future<List<ServerMealLog>> _fetchAround(DateTime day) async {
    final from = dateOnly(DateTime(day.year, day.month, day.day - 1));
    final to = dateOnly(DateTime(day.year, day.month, day.day + 1));
    final logs = <ServerMealLog>[];
    for (var page = 1; page <= _maxPages; page++) {
      final raw = await _api
          .get(_path, query: {'from': from, 'to': to, 'page': '$page'});
      if (raw is! Map) {
        throw const ParseException('The meal logs are not a page');
      }
      for (final item in jsonMaps(raw['data'])) {
        final log = ServerMealLog.fromJson(item);
        if (log != null) logs.add(log);
      }
      final last = jsonInt(jsonMap(raw['meta'])?['last_page']) ?? 1;
      if (page >= last) return logs;
    }
    // A partial list would make the logs after it look deleted.
    throw const ParseException('Too many pages of meal logs');
  }

  /// Keeps the server's id for a meal log the offline queue just saved, so its
  /// entry can be deleted there later (6.4). Other writes are ignored.
  Future<void> recordSaved(PendingWrite write, Object? response) async {
    if (write.path != _path || response is! Map) return;
    final key = write.body['idempotency_key'];
    final id = jsonInt(response['id']);
    if (key is! String || id == null) return;
    final saved = SentMealLog(
      key: key,
      serverId: id,
      editableUntil: jsonDateTime(response['editable_until']),
    );
    await _change((entries) => [
          for (final e in entries)
            if (e.sentLogs.any((log) => log.key == key))
              e.copyWith(sentLogs: [
                for (final log in e.sentLogs) log.key == key ? saved : log,
              ])
            else
              e,
        ]);
  }

  @override
  Future<Result<void>> clear() => guard(() => _change((_) => []));

  @override
  Future<void> forgetPatientData() {
    final forget = _changes.then((_) async {
      _cache = null;
      await _storage.remove(StorageKeys.mealLogEntries);
    });
    _changes = forget.catchError((Object _) {});
    return forget;
  }

  static List<SentMealLog> _sentLogsFor(List<Map<String, Object?>> bodies) => [
        for (final body in bodies)
          SentMealLog(key: body['idempotency_key']! as String),
      ];

  /// Saves [entry], then queues its [bodies] and sends them if there is a
  /// connection. The entry is saved first, so the server's answer to each log
  /// always finds it. If the logs cannot be queued, the entry is taken back
  /// out, so it is never shown without reaching the server.
  Future<void> _keep(
      MealLogEntry entry, List<Map<String, Object?>> bodies) async {
    await _change((entries) => [...entries, entry]);
    if (bodies.isEmpty) return;
    try {
      for (final body in bodies) {
        await _queue.enqueue(path: _path, body: body);
      }
    } on Object {
      final keys = {for (final log in entry.sentLogs) log.key};
      await _queue.removeWhere((write) =>
          write.path == _path && keys.contains(write.body['idempotency_key']));
      await _change((entries) => [
            for (final e in entries)
              if (e.id != entry.id) e,
          ]);
      rethrow;
    }
    await _queue.flush();
  }

  /// Applies [change] to the entries and saves the result, after any change
  /// already running.
  Future<void> _change(
      List<MealLogEntry> Function(List<MealLogEntry> entries) change) {
    final next = _changes.then((_) async {
      _cache = change(await _load());
      await _persist();
    });
    _changes = next.catchError((Object _) {});
    return next;
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

  Future<void> _persist() async {
    final entries = _cache ?? const <MealLogEntry>[];
    if (entries.isEmpty) {
      await _storage.remove(StorageKeys.mealLogEntries);
      return;
    }
    await _storage.writeMap(StorageKeys.mealLogEntries, {
      'entries':
          entries.map((e) => MealLogEntryDto.fromEntity(e).toJson()).toList(),
    });
  }
}
