import '../../core/logging/app_logger.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/nutritionist_entities.dart';

/// The nutritionist's WhatsApp number for the forgot-password message (API
/// guide 3.6 and 9.1).
///
/// The patient is signed out when they need it, so it is not one of the
/// patient caches that the end of a session clears (2.5). Only the number is
/// kept, and deleting the account removes it. Never throws.
class PasswordHelpContact {
  PasswordHelpContact(this._storage);

  static const DefaultAppLogger _log = DefaultAppLogger();

  final StorageService _storage;

  /// Keeps [whatsappNumber] from the latest `GET /me/nutritionist`, or forgets
  /// the kept one when the nutritionist has no number any more.
  Future<void> remember(String? whatsappNumber) async {
    try {
      final number = whatsappNumber?.trim() ?? '';
      if (number.isEmpty) {
        await _storage.remove(StorageKeys.passwordHelpContact);
      } else {
        await _storage.writeString(StorageKeys.passwordHelpContact, number);
      }
    } on Object catch (error) {
      _log.warn('The password help contact could not be kept', error: error);
    }
  }

  /// The `https://wa.me/` link of the kept number, or null when there is none.
  Future<Uri?> whatsappUri() async {
    try {
      final number = await _storage.readString(StorageKeys.passwordHelpContact);
      if (number == null) return null;
      return NutritionistProfile(name: '', whatsappNumber: number).whatsappUri;
    } on Object catch (error) {
      _log.warn('The password help contact could not be read', error: error);
      return null;
    }
  }

  Future<void> forget() async {
    try {
      await _storage.remove(StorageKeys.passwordHelpContact);
    } on Object catch (error) {
      _log.warn('The password help contact could not be removed',
          error: error);
    }
  }
}
