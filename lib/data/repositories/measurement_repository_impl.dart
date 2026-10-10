import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/measurement_entities.dart';
import '../../domain/repositories/measurement_repository.dart';
import '../datasources/measurement_data_source.dart';

/// Merges the baseline (clinic/mock) measurement data with locally saved
/// readings, so newly recorded weights show up in the trend chart and
/// headline numbers without a backend.
class MeasurementRepositoryImpl implements MeasurementRepository {
  MeasurementRepositoryImpl(this._storage, this._remote);

  final StorageService _storage;
  final MeasurementDataSource _remote;

  List<MeasurementEntry>? _cache;

  @override
  Future<Result<MeasurementSnapshot>> getSnapshot() => guard(() async {
        final baseline = await _remote.fetchBaseline();
        final saved = await _load();
        return _merge(baseline, saved);
      });

  @override
  Future<Result<MeasurementSnapshot>> saveEntry(MeasurementEntry entry) => guard(() async {
        final saved = await _load();
        _cache = [...saved, entry];
        await _storage.writeMap(StorageKeys.measurements, {
          'entries': _cache!.map((e) => e.toJson()).toList(),
        });
        final baseline = await _remote.fetchBaseline();
        return _merge(baseline, _cache!);
      });

  MeasurementSnapshot _merge(MeasurementBaseline baseline, List<MeasurementEntry> saved) {
    if (saved.isEmpty) {
      return MeasurementSnapshot(
        currentWeight: baseline.currentWeight,
        previousWeight: baseline.previousWeight,
        weightTrend: baseline.weightTrend,
        circumference: baseline.circumference,
        daysLoggedThisWeek: baseline.daysLoggedThisWeek,
        daysLoggedThisMonth: baseline.daysLoggedThisMonth,
        savedEntries: saved,
      );
    }

    final withWeight = saved.where((e) => e.weightKg != null).toList();
    final trend = [...baseline.weightTrend];
    double current = baseline.currentWeight;
    double previous = baseline.previousWeight;
    if (withWeight.isNotEmpty) {
      final latest = withWeight.last;
      current = latest.weightKg!;
      trend.addAll(withWeight.map(
        (e) => WeightPoint(date: e.recordedAt, kg: e.weightKg!, clinicVerified: false),
      ));
      trend.sort((a, b) => a.date.compareTo(b.date));
      previous = withWeight.length > 1 ? withWeight[withWeight.length - 2].weightKg! : baseline.previousWeight;
    }

    // Circumference readings update the matching baseline stat (and its delta).
    var circumference = baseline.circumference;
    final latestEntry = saved.last;
    circumference = circumference.map((stat) {
      final next = switch (stat.label) {
        'محيط الخصر' => latestEntry.waistCm,
        'محيط الورك' => latestEntry.hipCm,
        'محيط الفخذ' => latestEntry.thighCm,
        'محيط الذراع' => latestEntry.armCm,
        _ => null,
      };
      if (next == null) return stat;
      final delta = next - stat.valueCm;
      return CircumferenceStat(label: stat.label, valueCm: next, deltaCm: double.parse(delta.toStringAsFixed(1)));
    }).toList();

    final now = DateTime.now();
    final inLast = (Duration d) => saved.where((e) => now.difference(e.recordedAt) <= d).length;

    return MeasurementSnapshot(
      currentWeight: current,
      previousWeight: previous,
      weightTrend: trend,
      circumference: circumference,
      daysLoggedThisWeek: baseline.daysLoggedThisWeek + inLast(const Duration(days: 7)),
      daysLoggedThisMonth: baseline.daysLoggedThisMonth + inLast(const Duration(days: 30)),
      savedEntries: saved,
    );
  }

  Future<List<MeasurementEntry>> _load() async {
    final cached = _cache;
    if (cached != null) return cached;
    try {
      final raw = await _storage.readMap(StorageKeys.measurements);
      final list = raw?['entries'];
      _cache = list is List
          ? list.whereType<Map<String, dynamic>>().map(MeasurementEntry.fromJson).whereType<MeasurementEntry>().toList()
          : [];
    } on Object {
      _cache = [];
    }
    return _cache!;
  }
}
