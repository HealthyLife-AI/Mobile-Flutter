import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/review_entities.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';
import '../models/review_dto.dart';

/// The nutritionist's notes (API guide 9.2). The last list is kept on the
/// device, so the notes can be read offline. The copy is cleared at sign-out
/// with the rest of the patient's data (2.5).
class ReviewRepositoryImpl implements ReviewRepository, PatientCache {
  ReviewRepositoryImpl(this._storage, this._remote);

  static const DefaultAppLogger _log = DefaultAppLogger();

  final StorageService _storage;
  final ReviewRemoteDataSource _remote;

  @override
  Future<Result<List<NutritionistReview>>> getReviews() => guard(() async {
        try {
          final raw = await _remote.fetchReviews();
          await _remember(raw);
          return _parse(raw);
        } on NetworkException {
          // No connection: show the last list, when there is one.
          final kept = await _remembered();
          if (kept == null) rethrow;
          return kept;
        }
      });

  @override
  Future<Result<void>> acknowledge(int reviewId) =>
      guard(() => _remote.acknowledge(reviewId));

  @override
  Future<Result<void>> setTaskDone(int taskId, {required bool done}) =>
      guard(() => _remote.setTaskDone(taskId, done: done));

  @override
  Future<void> forgetPatientData() => _storage.remove(StorageKeys.reviews);

  static List<NutritionistReview> _parse(List<Map<String, dynamic>> raw) =>
      raw.map(ReviewDto.fromJson).whereType<NutritionistReview>().toList();

  Future<List<NutritionistReview>?> _remembered() async {
    try {
      final raw = await _storage.readMap(StorageKeys.reviews);
      final items = raw?['items'];
      if (items is! List) return null;
      return _parse([
        for (final item in items)
          if (item is Map) Map<String, dynamic>.from(item),
      ]);
    } on Object catch (error) {
      _log.warn('The kept notes could not be read', error: error);
      return null;
    }
  }

  /// A failure to keep the copy does not fail a read that succeeded.
  Future<void> _remember(List<Map<String, dynamic>> raw) async {
    try {
      await _storage.writeMap(StorageKeys.reviews, {'items': raw});
    } on Object catch (error) {
      _log.warn('The notes could not be kept on this device', error: error);
    }
  }
}
