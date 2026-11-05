import '../../core/logging/app_logger.dart';
import '../../core/storage/storage_service.dart';

/// The address of the privacy policy published on the website (API guide 4:
/// `policy_url`, in the patient's language).
///
/// The last address the server sent is kept on the device after the session
/// ends, so a screen without a session (follow-up ended) can still open it.
/// It is a public page, not patient data. Never throws.
class PrivacyPolicyLink {
  PrivacyPolicyLink(this._storage);

  static const DefaultAppLogger _log = DefaultAppLogger();

  final StorageService _storage;

  /// [raw] as a web address, or null when it is not one.
  static Uri? usable(String? raw) {
    final uri = raw == null ? null : Uri.tryParse(raw.trim());
    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return null;
    }
    return uri;
  }

  /// Keeps [policyUrl] when it is a web address. A missing one leaves the
  /// address already kept.
  Future<void> remember(String? policyUrl) async {
    final uri = usable(policyUrl);
    if (uri == null) return;
    try {
      await _storage.writeString(StorageKeys.privacyPolicyUrl, '$uri');
    } on Object catch (error) {
      _log.warn('The privacy policy address could not be kept', error: error);
    }
  }

  /// The last address kept, or null.
  Future<Uri?> last() async {
    try {
      return usable(await _storage.readString(StorageKeys.privacyPolicyUrl));
    } on Object catch (error) {
      _log.warn('The privacy policy address could not be read', error: error);
      return null;
    }
  }
}
