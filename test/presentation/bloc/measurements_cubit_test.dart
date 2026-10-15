import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/domain/entities/measurement_entities.dart';
import 'package:healthylife_ai/domain/repositories/measurement_repository.dart';
import 'package:healthylife_ai/presentation/bloc/measurements/measurements_cubit.dart';

class _Repository implements MeasurementRepository {
  _Repository(this.readings);

  List<MeasurementEntry> readings;

  @override
  Future<Result<MeasurementSnapshot>> getSnapshot() async =>
      Success(snapshotOf(readings));

  @override
  Future<Result<MeasurementSnapshot>> saveEntry(MeasurementEntry entry) =>
      throw UnimplementedError();
}

MeasurementSnapshot snapshotOf(List<MeasurementEntry> readings) =>
    MeasurementSnapshot(
      currentWeight: readings.isEmpty ? null : readings.last.weightKg,
      previousWeight: null,
      weightTrend: [
        for (final r in readings)
          WeightPoint(date: r.recordedAt, kg: r.weightKg!),
      ],
      circumference: const [],
      daysLoggedThisWeek: 0,
      daysLoggedThisMonth: 0,
      savedEntries: readings,
    );

MeasurementEntry reading(DateTime day) =>
    MeasurementEntry(id: '$day', recordedAt: day, weightKg: 80);

void main() {
  final now = DateTime(2026, 10, 15, 10);

  test('no reading: empty, and not counted as a weekly reading due', () async {
    final cubit = MeasurementsCubit(_Repository([]), clock: () => now);

    await cubit.load();

    expect(cubit.state.status, MeasurementsStatus.empty);
    expect(cubit.state.measurementDue, isFalse);
  });

  test('a reading from this week: loaded, nothing due', () async {
    final cubit = MeasurementsCubit(
        _Repository([reading(DateTime(2026, 10, 12))]),
        clock: () => now);

    await cubit.load();

    expect(cubit.state.status, MeasurementsStatus.loaded);
    expect(cubit.state.measurementDue, isFalse);
  });

  test('the latest reading is a week old: the weekly reading is due', () async {
    final cubit = MeasurementsCubit(
        _Repository([reading(DateTime(2026, 10, 8))]),
        clock: () => now);

    await cubit.load();

    expect(cubit.state.status, MeasurementsStatus.loaded);
    expect(cubit.state.measurementDue, isTrue);
  });

  test('a new reading clears the due flag on the next load', () async {
    final repository = _Repository([reading(DateTime(2026, 10, 8))]);
    final cubit = MeasurementsCubit(repository, clock: () => now);
    await cubit.load();

    repository.readings = [...repository.readings, reading(now)];
    await cubit.load();

    expect(cubit.state.measurementDue, isFalse);
  });
}
