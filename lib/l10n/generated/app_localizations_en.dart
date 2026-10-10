// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'HealthyLife AI';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDone => 'Done';

  @override
  String get commonClose => 'Close';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonEmptyTitle => 'Nothing to show yet';

  @override
  String get commonEmptyBody =>
      'Information will appear here as soon as it\'s available.';

  @override
  String get commonErrorTitle => 'Something went wrong';

  @override
  String get commonErrorBody => 'We couldn\'t load the data. Please try again.';

  @override
  String get commonOfflineTitle => 'No internet connection';

  @override
  String get commonOfflineBody => 'Check your network and try again.';

  @override
  String get commonSuccess => 'Done successfully';

  @override
  String get failureNetwork =>
      'Could not reach the server. Check your connection and try again.';

  @override
  String get failureTimeout => 'The request took too long. Please try again.';

  @override
  String get failureServer =>
      'The service is unavailable right now. Try again later.';

  @override
  String get failureUnauthorized =>
      'Your session has expired. Please sign in again.';

  @override
  String get failureNotFound => 'The requested item was not found.';

  @override
  String get failureValidation => 'Please check your input and try again.';

  @override
  String get failureCache => 'Could not read locally saved data.';

  @override
  String get failureUnexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationInvalidEmail => 'Enter a valid email address';

  @override
  String validationTooShort(int min) {
    return 'Must be at least $min characters';
  }

  @override
  String validationTooLong(int max) {
    return 'Must not exceed $max characters';
  }

  @override
  String get validationMissingUppercase => 'Add at least one uppercase letter';

  @override
  String get validationMissingDigit => 'Add at least one digit';

  @override
  String get validationMissingSpecial => 'Add at least one special character';

  @override
  String get validationMismatch => 'The two values don\'t match';

  @override
  String get validationInvalidNumber => 'Numbers only';

  @override
  String validationOutOfRange(num min, num max) {
    return 'Value must be between $min and $max';
  }
}
