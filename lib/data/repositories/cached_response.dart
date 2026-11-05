import '../../core/errors/app_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../core/storage/patient_cache.dart';
import '../../core/storage/storage_service.dart';

/// The last answer of one GET, kept on the device so the screen still shows
/// without a connection. Cleared at sign-out with the patient's other data
/// (API guide 2.5), which is why it is a [PatientCache].
///
/// Any JSON value is kept, `null` included (an endpoint that answers "none").
class CachedResponse implements PatientCache {
  CachedResponse(this._storage, this._key);

  static const DefaultAppLogger _log = DefaultAppLogger();

  final StorageService _storage;
  final String _key;

  /// Reads through the network: a fresh answer replaces the kept copy; with
  /// no connection, the kept copy is parsed instead. Without a copy the
  /// network error is rethrown, so the screen shows its offline state.
  ///
  /// [parse] runs before the answer is kept, so a body the app cannot read
  /// never replaces a good copy.
  Future<T> read<T>(
    Future<Object?> Function() fetch,
    T Function(Object? raw) parse,
  ) async {
    try {
      final raw = await fetch();
      final value = parse(raw);
      await _remember(raw);
      return value;
    } on NetworkException {
      final kept = await _remembered();
      if (kept == null) rethrow;
      return parse(kept.raw);
    }
  }

  /// Replaces the kept copy after a write that returned the new state.
  Future<void> replace(Object? raw) => _remember(raw);

  @override
  Future<void> forgetPatientData() => _storage.remove(_key);

  Future<({Object? raw})?> _remembered() async {
    try {
      final kept = await _storage.readMap(_key);
      if (kept == null || !kept.containsKey('raw')) return null;
      return (raw: kept['raw']);
    } on Object catch (error) {
      _log.warn('A kept answer could not be read ($_key)', error: error);
      return null;
    }
  }

  /// A failure to keep the copy does not fail a read that succeeded.
  Future<void> _remember(Object? raw) async {
    try {
      await _storage.writeMap(_key, {'raw': raw});
    } on Object catch (error) {
      _log.warn('An answer could not be kept ($_key)', error: error);
    }
  }
}
