import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';
import '../../core/time/date_only.dart';
import '../../domain/entities/progress_entities.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_remote_data_source.dart';
import '../models/progress_dto.dart';

/// The patient's progress (API guide 8). The last answer is kept on the device
/// with the window it was read for, so the same window can be shown offline.
/// A different window is not shown from the copy, because the chart would
/// show the wrong days. The copy is cleared at sign-out (2.5).
class ProgressRepositoryImpl implements ProgressRepository, PatientCache {
  ProgressRepositoryImpl(this._storage, this._remote);

  static const DefaultAppLogger _log = DefaultAppLogger();

  final StorageService _storage;
  final ProgressRemoteDataSource _remote;

  @override
  Future<Result<ProgressSnapshot>> getProgress({
    required DateTime from,
    required DateTime to,
  }) =>
      guard(() async {
        final window = _window(from, to);
        try {
          final raw = await _remote.fetch(from: from, to: to);
          await _remember(window, raw);
          return ProgressDto.fromJson(raw);
        } on NetworkException {
          // No connection: the copy, but only for the same window.
          final kept = await _remembered(window);
          if (kept == null) rethrow;
          return kept;
        }
      });

  @override
  Future<void> forgetPatientData() => _storage.remove(StorageKeys.progress);

  static String _window(DateTime from, DateTime to) =>
      '${dateOnly(from)}..${dateOnly(to)}';

  Future<ProgressSnapshot?> _remembered(String window) async {
    try {
      final kept = await _storage.readMap(StorageKeys.progress);
      if (kept?['window'] != window) return null;
      final raw = kept?['raw'];
      if (raw is! Map) return null;
      return ProgressDto.fromJson(Map<String, dynamic>.from(raw));
    } on Object catch (error) {
      _log.warn('The kept progress could not be read', error: error);
      return null;
    }
  }

  /// A failure to keep the copy does not fail a read that succeeded.
  Future<void> _remember(String window, Map<String, dynamic> raw) async {
    try {
      await _storage.writeMap(StorageKeys.progress, {
        'window': window,
        'raw': raw,
      });
    } on Object catch (error) {
      _log.warn('The progress could not be kept on this device', error: error);
    }
  }
}
