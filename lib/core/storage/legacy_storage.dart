import '../logging/app_logger.dart';
import 'storage_service.dart';

/// Keys written by builds from before the API read path. Nothing reads them any
/// more: the readings come from the server, and the session from the secure
/// vault. They stayed on devices that never signed out, so start-up removes them.
const List<String> legacyStorageKeys = [
  StorageKeys.session,
  StorageKeys.measurements,
];

/// Removes [legacyStorageKeys] from [storage]. A key that is not there is not an
/// error. A removal that fails is logged and does not stop start-up, because
/// nothing reads these keys, so leaving one behind changes nothing for the
/// patient.
Future<void> removeLegacyStorage(StorageService storage) async {
  const DefaultAppLogger log = DefaultAppLogger();
  for (final key in legacyStorageKeys) {
    try {
      await storage.remove(key);
    } on Object catch (error) {
      log.warn('A leftover key could not be removed', error: error);
    }
  }
}
