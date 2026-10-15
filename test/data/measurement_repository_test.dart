import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/core/sync/offline_queue.dart';
import 'package:healthylife_ai/data/datasources/measurement_remote_data_source.dart';
import 'package:healthylife_ai/data/repositories/measurement_repository_impl.dart';
import 'package:healthylife_ai/domain/entities/measurement_entities.dart';

/// Answers the calls the repository makes. Each GET takes the next scripted
/// answer: a value is returned, an [AppException] is thrown. Each POST takes
/// the next scripted failure, or succeeds when none is left.
class _ScriptedApi implements ApiClient {
  final List<Object> gets = [];
  final List<AppException?> posts = [];
  final List<({String path, Map<String, dynamic> body})> sent = [];

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    if (gets.isEmpty) throw StateError('No GET answer scripted for $path');
    final next = gets.removeAt(0);
    if (next is AppException) throw next;
    return next;
  }

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    sent.add((
      path: path,
      body: body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{},
    ));
    final next = posts.isEmpty ? null : posts.removeAt(0);
    if (next != null) throw next;
    return null;
  }

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);
}

/// One reading as the API returns it (7.1, 7.2).
Map<String, dynamic> _reading(
  int id,
  String day, {
  String source = 'self-reported',
  double? weight,
  double? waist,
  double? hip,
}) =>
    {
      'id': id,
      'recorded_at': day,
      'source': source,
      'weight_kg': weight,
      'waist_cm': waist,
      'hip_cm': hip,
    };

const _offline = NetworkException('offline', kind: NetworkFailureKind.offline);

void main() {
  final now = DateTime(2026, 10, 7, 12);
  late MemoryStorageService storage;
  late _ScriptedApi api;
  late OfflineQueue queue;

  MeasurementRepositoryImpl build() => MeasurementRepositoryImpl(
        storage,
        MeasurementRemoteDataSource(api),
        queue,
        clock: () => now,
      );

  late MeasurementRepositoryImpl repository;

  setUp(() {
    storage = MemoryStorageService();
    api = _ScriptedApi();
    queue = OfflineQueue(
      storage: storage,
      api: api,
      clock: () => now,
      pause: (_) async {},
    );
    repository = build();
  });

  test(
      'a reading is sent with the patient\'s own day, then read back (7.1, 7.2)',
      () async {
    api.gets.add([_reading(10, '2026-10-07', weight: 82.5, waist: 92.5)]);

    final result = await repository.saveEntry(MeasurementEntry(
      id: 'local',
      recordedAt: DateTime(2026, 10, 7, 21, 30),
      weightKg: 82.5,
      waistCm: 92.5,
    ));

    expect(api.sent.single.path, 'me/measurements');
    expect(api.sent.single.body, {
      'weight_kg': 82.5,
      'waist_cm': 92.5,
      'recorded_at': '2026-10-07',
    });
    final snapshot = result.valueOrNull!;
    expect(snapshot.currentWeight, 82.5);
    expect(snapshot.savedEntries.single.id, '10');
    expect(snapshot.savedEntries.single.pending, isFalse);
    expect(await queue.pendingCount(), 0);
  });

  test('a reading made offline is queued and shown as pending', () async {
    api.posts.add(_offline);
    api.gets.add(_offline);

    final result = await repository.saveEntry(MeasurementEntry(
      id: 'local',
      recordedAt: DateTime(2026, 10, 7),
      weightKg: 80,
    ));

    expect(result.isSuccess, isTrue);
    expect(await queue.pendingCount(), 1);
    final snapshot = result.valueOrNull!;
    expect(snapshot.currentWeight, 80);
    expect(snapshot.savedEntries.single.pending, isTrue);
  });

  test('the last answer stays on the device for a read without a connection',
      () async {
    api.gets.add([_reading(1, '2026-10-05', weight: 79)]);
    await repository.getSnapshot();

    // A new run of the app: nothing in memory, only what was stored.
    api.gets.add(_offline);
    final result = await build().getSnapshot();

    expect(result.valueOrNull!.currentWeight, 79);
  });

  test('offline with no stored answer and nothing queued is a failure',
      () async {
    api.gets.add(_offline);

    final result = await repository.getSnapshot();

    expect(result.isSuccess, isFalse);
  });

  test('an answer that is not a list is a failed read', () async {
    api.gets.add({'id': 1});

    final result = await repository.getSnapshot();

    expect(result.isSuccess, isFalse);
  });

  test('a circumference is compared with the last reading that measured it',
      () async {
    api.gets.add([
      _reading(1, '2026-10-01', waist: 90),
      _reading(2, '2026-10-05', weight: 80),
      _reading(3, '2026-10-07', waist: 92.5, hip: 100),
    ]);

    final snapshot = (await repository.getSnapshot()).valueOrNull!;

    final waist = snapshot.circumference
        .singleWhere((s) => s.part == CircumferencePart.waist);
    expect(waist.valueCm, 92.5);
    expect(waist.deltaCm, 2.5);
    // Measured once only, so there is nothing to compare with.
    final hip = snapshot.circumference
        .singleWhere((s) => s.part == CircumferencePart.hip);
    expect(hip.valueCm, 100);
    expect(hip.deltaCm, isNull);
    expect(
      snapshot.circumference.any((s) => s.part == CircumferencePart.thigh),
      isFalse,
    );
  });

  test('days logged count the patient\'s own days over 7 and 30 days',
      () async {
    api.gets.add([
      _reading(1, '2026-08-01', weight: 90), // outside 30 days
      _reading(2, '2026-09-20', weight: 85), // inside 30, outside 7
      _reading(3, '2026-10-02', weight: 84), // inside 7
      _reading(4, '2026-10-07', weight: 83),
      _reading(5, '2026-10-07', waist: 92), // same day as 4, counted once
      _reading(6, '2026-10-05', source: 'clinic-analyser', weight: 84),
    ]);

    final snapshot = (await repository.getSnapshot()).valueOrNull!;

    expect(snapshot.daysLoggedThisWeek, 2);
    expect(snapshot.daysLoggedThisMonth, 3);
  });

  test('forgetting the patient removes the answer from memory and disk',
      () async {
    api.gets.add([_reading(1, '2026-10-05', weight: 79)]);
    await repository.getSnapshot();

    await repository.forgetPatientData();

    expect(await storage.containsKey(StorageKeys.measurementReadings), isFalse);
    api.gets.add(_offline);
    expect((await repository.getSnapshot()).isSuccess, isFalse);
  });
}
