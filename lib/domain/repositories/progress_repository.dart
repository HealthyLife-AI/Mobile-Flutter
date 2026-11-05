import '../../core/errors/result.dart';
import '../entities/progress_entities.dart';

/// The patient's progress over a window of dates (API guide 8).
abstract interface class ProgressRepository {
  /// Progress from [from] to [to], both included. Only the calendar dates of
  /// the two values are used, and they are sent as clinic dates (1.2).
  Future<Result<ProgressSnapshot>> getProgress({
    required DateTime from,
    required DateTime to,
  });
}
