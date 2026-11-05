import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/domain/entities/measurement_entities.dart';
import 'package:healthylife_ai/domain/repositories/measurement_repository.dart';
import 'package:healthylife_ai/domain/usecases/save_measurement_use_case.dart';

const _snapshot = MeasurementSnapshot(
  currentWeight: 80,
  previousWeight: 80,
  weightTrend: [],
  circumference: [],
  daysLoggedThisWeek: 0,
  daysLoggedThisMonth: 0,
  savedEntries: [],
);

class _Repository implements MeasurementRepository {
  final List<MeasurementEntry> saved = [];

  @override
  Future<Result<MeasurementSnapshot>> getSnapshot() async =>
      throw UnimplementedError();

  @override
  Future<Result<MeasurementSnapshot>> saveEntry(MeasurementEntry entry) async {
    saved.add(entry);
    return Success(_snapshot);
  }
}

MeasurementEntry _entry({
  double? weight = 82.5,
  double? waist,
  double? hip,
  double? thigh,
  double? arm,
}) =>
    MeasurementEntry(
      id: 'new',
      recordedAt: DateTime(2026, 10, 7),
      weightKg: weight,
      waistCm: waist,
      hipCm: hip,
      thighCm: thigh,
      armCm: arm,
    );

void main() {
  late _Repository repository;
  late SaveMeasurementUseCase save;

  setUp(() {
    repository = _Repository();
    save = SaveMeasurementUseCase(repository);
  });

  test('a reading without a weight is refused: the server needs it (7.1)',
      () async {
    final result = await save(_entry(weight: null, waist: 92.5));

    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(repository.saved, isEmpty);
  });

  test('a weight outside 20 to 300 kg is refused', () async {
    expect((await save(_entry(weight: 19.9))).failureOrNull,
        isA<ValidationFailure>());
    expect((await save(_entry(weight: 300.1))).failureOrNull,
        isA<ValidationFailure>());
    expect(repository.saved, isEmpty);
  });

  test('circumferences use the API ranges (7.1)', () async {
    // Accepted at the edges.
    expect(
        (await save(_entry(waist: 20, hip: 300, thigh: 10, arm: 150)))
            .isSuccess,
        isTrue);
    // Refused just past each edge.
    expect((await save(_entry(arm: 150.1))).failureOrNull,
        isA<ValidationFailure>());
    expect((await save(_entry(thigh: 9.9))).failureOrNull,
        isA<ValidationFailure>());
    expect((await save(_entry(hip: 300.1))).failureOrNull,
        isA<ValidationFailure>());
  });

  test('a refusal names each field that is out of range', () async {
    final result = await save(_entry(weight: 301, hip: 300.1, arm: 9));
    final failure = result.failureOrNull as ValidationFailure;

    expect(failure.fieldErrors.keys, unorderedEquals(['weight', 'hip', 'arm']));
    expect(repository.saved, isEmpty);
  });

  test('a valid reading reaches the repository', () async {
    final result = await save(_entry(waist: 92.5));

    expect(result.isSuccess, isTrue);
    expect(repository.saved.single.weightKg, 82.5);
  });
}
