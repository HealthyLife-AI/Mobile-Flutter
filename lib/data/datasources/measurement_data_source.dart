import '../../core/config/app_config.dart';
import '../../domain/entities/measurement_entities.dart';
import '../mock/measurement_mock_data.dart';

/// Baseline measurement data (what the clinic/API would provide for the
/// progress screens). Locally saved readings are merged on top by the
/// repository.
class MeasurementBaseline {
  const MeasurementBaseline({
    required this.currentWeight,
    required this.previousWeight,
    required this.weightTrend,
    required this.circumference,
    required this.daysLoggedThisWeek,
    required this.daysLoggedThisMonth,
  });

  final double currentWeight;
  final double previousWeight;
  final List<WeightPoint> weightTrend;
  final List<CircumferenceStat> circumference;
  final int daysLoggedThisWeek;
  final int daysLoggedThisMonth;
}

abstract interface class MeasurementDataSource {
  Future<MeasurementBaseline> fetchBaseline();
}

class MockMeasurementDataSource implements MeasurementDataSource {
  const MockMeasurementDataSource({this.latency = AppConfig.mockLatency});

  final Duration latency;

  @override
  Future<MeasurementBaseline> fetchBaseline() async {
    await Future<void>.delayed(latency);
    return MeasurementBaseline(
      currentWeight: MeasurementMockData.currentWeight,
      previousWeight: MeasurementMockData.previousWeight,
      weightTrend: List.unmodifiable(MeasurementMockData.weightTrend),
      circumference: MeasurementMockData.circumference,
      daysLoggedThisWeek: MeasurementMockData.daysLoggedThisWeek,
      daysLoggedThisMonth: MeasurementMockData.daysLoggedThisMonth,
    );
  }
}
