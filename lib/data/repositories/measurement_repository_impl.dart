import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/failure.dart';
import '../../core/errors/result.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../core/sync/offline_queue.dart';
import '../../core/time/date_only.dart';
import '../../domain/entities/measurement_entities.dart';
import '../../domain/repositories/measurement_repository.dart';
import '../datasources/measurement_remote_data_source.dart';
import '../models/measurement_dto.dart';

/// Body measurements from `GET /me/measurements` (7.2), with the readings still
/// waiting in the offline queue (14) added on top.
///
/// The last server answer is kept on the device, so the patient still sees
/// their readings without a connection.
class MeasurementRepositoryImpl implements MeasurementRepository, PatientCache {
  MeasurementRepositoryImpl(
    this._storage,
    this._remote,
    this._queue, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const DefaultAppLogger _log = DefaultAppLogger();
  static const String _path = 'me/measurements';

  /// The four circumferences, in the order the screen shows them. The screen
  /// names each part in the patient's language.
  static final List<(CircumferencePart, double? Function(MeasurementEntry))>
      _circumferences = [
    (CircumferencePart.waist, (e) => e.waistCm),
    (CircumferencePart.hip, (e) => e.hipCm),
    (CircumferencePart.thigh, (e) => e.thighCm),
    (CircumferencePart.arm, (e) => e.armCm),
  ];

  final StorageService _storage;
  final MeasurementRemoteDataSource _remote;
  final OfflineQueue _queue;
  final DateTime Function() _clock;

  /// The last server answer, once it has been read or loaded in this run.
  List<MeasurementEntry>? _cache;

  @override
  Future<Result<MeasurementSnapshot>> getSnapshot() => guard(() async {
        try {
          final readings = await _remote.fetchReadings();
          await _remember(readings);
          return _compose(readings, await _waiting());
        } on NetworkException {
          // No connection: the last answer, then whatever is still queued.
          final last = await _remembered();
          final waiting = await _waiting();
          if (last == null && waiting.isEmpty) rethrow;
          return _compose(last ?? const [], waiting);
        }
      });

  @override
  Future<Result<MeasurementSnapshot>> saveEntry(MeasurementEntry entry) async {
    // Queued first, so a reading made offline is still sent after a restart.
    final queued = await guard(
      () => _queue.enqueue(path: _path, body: _body(entry)),
    );
    if (!queued.isSuccess) {
      return Failed(queued.failureOrNull ?? const UnexpectedFailure());
    }
    // Sent now when there is a connection. Otherwise the reading stays in the
    // queue and is read back below as a pending reading.
    await _queue.flush();
    return getSnapshot();
  }

  @override
  Future<void> forgetPatientData() async {
    _cache = null;
    await _storage.remove(StorageKeys.measurementReadings);
    await _storage.remove(StorageKeys.measurements); // legacy local readings
  }

  /// The body of `POST /me/measurements` (7.1). Circumferences that were not
  /// measured are left out. The date is the patient's own day.
  static Map<String, dynamic> _body(MeasurementEntry entry) => {
        'weight_kg': entry.weightKg,
        if (entry.waistCm != null) 'waist_cm': entry.waistCm,
        if (entry.hipCm != null) 'hip_cm': entry.hipCm,
        if (entry.thighCm != null) 'thigh_cm': entry.thighCm,
        if (entry.armCm != null) 'arm_cm': entry.armCm,
        'recorded_at': dateOnly(entry.recordedAt),
      };

  /// Readings still waiting in the offline queue.
  Future<List<MeasurementEntry>> _waiting() async {
    final waiting = <MeasurementEntry>[];
    for (final write in await _queue.pendingWrites()) {
      if (write.path != _path) continue;
      final reading = MeasurementDto.waitingFromWrite(write);
      if (reading != null) waiting.add(reading);
    }
    return waiting;
  }

  MeasurementSnapshot _compose(
    List<MeasurementEntry> server,
    List<MeasurementEntry> waiting,
  ) {
    final all = _chronological([...server, ...waiting]);

    final weighed = [
      for (final e in all)
        if (e.weightKg != null) e,
    ];
    final trend = [
      for (final e in weighed)
        WeightPoint(
          date: e.recordedAt,
          kg: e.weightKg!,
          clinicVerified: e.source == ReadingSource.clinicAnalyser,
        ),
    ];

    // Latest value of each circumference, with the change from the reading
    // before it that measured the same part.
    final circumference = <CircumferenceStat>[];
    for (final (part, valueOf) in _circumferences) {
      final measured = [
        for (final e in all)
          if (valueOf(e) != null) e,
      ];
      if (measured.isEmpty) continue;
      final latest = valueOf(measured.last)!;
      final before =
          measured.length > 1 ? valueOf(measured[measured.length - 2]) : null;
      circumference.add(CircumferenceStat(
        part: part,
        valueCm: latest,
        deltaCm: before == null ? null : _oneDecimal(latest - before),
      ));
    }

    final today = _today();
    return MeasurementSnapshot(
      currentWeight: weighed.isEmpty ? null : weighed.last.weightKg,
      previousWeight:
          weighed.length < 2 ? null : weighed[weighed.length - 2].weightKg,
      weightTrend: trend,
      circumference: circumference,
      daysLoggedThisWeek: _daysLogged(all, today, days: 7),
      daysLoggedThisMonth: _daysLogged(all, today, days: 30),
      savedEntries: all,
    );
  }

  /// Oldest first. Readings on the same day keep the order they came in:
  /// the server's first, then the queued ones.
  static List<MeasurementEntry> _chronological(
    List<MeasurementEntry> readings,
  ) {
    final order = List<int>.generate(readings.length, (i) => i)
      ..sort((a, b) {
        final byDay = readings[a].recordedAt.compareTo(readings[b].recordedAt);
        return byDay != 0 ? byDay : a.compareTo(b);
      });
    return [for (final i in order) readings[i]];
  }

  /// Distinct days in the last [days] days, today included, on which the
  /// patient logged a reading themselves. Clinic readings are not the
  /// patient's logs, so they are not counted.
  static int _daysLogged(
    List<MeasurementEntry> readings,
    DateTime today, {
    required int days,
  }) {
    final first = DateTime(today.year, today.month, today.day - (days - 1));
    final logged = <String>{};
    for (final e in readings) {
      if (e.source != ReadingSource.selfReported) continue;
      final day =
          DateTime(e.recordedAt.year, e.recordedAt.month, e.recordedAt.day);
      if (day.isBefore(first) || day.isAfter(today)) continue;
      logged.add(dateOnly(day));
    }
    return logged.length;
  }

  DateTime _today() {
    final now = _clock();
    return DateTime(now.year, now.month, now.day);
  }

  static double _oneDecimal(double value) =>
      double.parse(value.toStringAsFixed(1));

  Future<void> _remember(List<MeasurementEntry> readings) async {
    _cache = readings;
    try {
      await _storage.writeMap(StorageKeys.measurementReadings, {
        'readings': [for (final r in readings) r.toJson()],
      });
    } on Object catch (error) {
      _log.warn('Measurements could not be kept on this device', error: error);
    }
  }

  /// The last saved answer, or null when there is none.
  Future<List<MeasurementEntry>?> _remembered() async {
    final cached = _cache;
    if (cached != null) return cached;
    try {
      final raw = await _storage.readMap(StorageKeys.measurementReadings);
      final list = raw?['readings'];
      if (list is! List) return null;
      final loaded = <MeasurementEntry>[];
      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final entry = MeasurementEntry.fromJson(item);
        if (entry != null) loaded.add(entry);
      }
      _cache = loaded;
      return loaded;
    } on Object catch (error) {
      _log.warn('Stored measurements could not be read', error: error);
      return null;
    }
  }
}
