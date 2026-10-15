import '../logging/app_logger.dart';
import 'storage_service.dart';

/// Data kept on this device about the signed-in patient. It is forgotten when
/// the session ends, so the next person to sign in cannot see it (API guide
/// 2.5).
///
/// Every repository that holds patient data, in memory or in storage,
/// implements this. Clearing only the stored copy would leave the in-memory
/// copy for the next patient in the same run.
abstract interface class PatientCache {
  /// Forgets the patient's data, in memory and on disk. Throws when storage
  /// fails; [forgetPatientCaches] decides what happens then.
  Future<void> forgetPatientData();
}

/// Runs each cache in the order given. A failure is logged and the rest still
/// run, so sign-out removes as much as it can.
Future<void> forgetPatientCaches(Iterable<PatientCache> caches) async {
  for (final cache in caches) {
    try {
      await cache.forgetPatientData();
    } catch (error) {
      const DefaultAppLogger()
          .warn('Patient data could not be cleared', error: error);
    }
  }
}

/// Stored values that belong to one patient and have no repository of their
/// own. They are removed by key.
class StoredPatientData implements PatientCache {
  StoredPatientData(this._storage, this._keys);

  final StorageService _storage;
  final List<String> _keys;

  @override
  Future<void> forgetPatientData() async {
    for (final key in _keys) {
      await _storage.remove(key);
    }
  }
}
