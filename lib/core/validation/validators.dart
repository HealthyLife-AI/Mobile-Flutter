/// Centralized, UI-independent validation.
///
/// Validators return a machine-readable [ValidationCode] instead of a string
/// so messages stay localizable (presentation maps codes to l10n strings)
/// and so the exact same rules can be unit-tested without a widget tree.
enum ValidationCode {
  required,
  invalidEmail,
  tooShort,
  tooLong,
  missingUppercase,
  missingDigit,
  missingSpecial,
  mismatch,
  invalidNumber,
  outOfRange,
}

class ValidationError {
  const ValidationError(this.code, {this.min, this.max});

  final ValidationCode code;
  final num? min;
  final num? max;
}

class Validators {
  Validators._();

  static ValidationError? required(String? value) {
    if (value == null || value.trim().isEmpty) return const ValidationError(ValidationCode.required);
    return null;
  }

  static final RegExp _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static ValidationError? email(String? value) {
    final req = required(value);
    if (req != null) return req;
    if (!_email.hasMatch(value!.trim())) return const ValidationError(ValidationCode.invalidEmail);
    return null;
  }

  static ValidationError? length(String? value, {int? min, int? max}) {
    final v = value ?? '';
    if (min != null && v.length < min) return ValidationError(ValidationCode.tooShort, min: min);
    if (max != null && v.length > max) return ValidationError(ValidationCode.tooLong, max: max);
    return null;
  }

  /// Parses a decimal number (accepts both `.` and `,` as separator) and
  /// range-checks it. Used by measurement/quantity fields.
  static ValidationError? numberInRange(String? value, {required num min, required num max}) {
    final req = required(value);
    if (req != null) return req;
    final normalized = value!.trim().replaceAll(',', '.');
    final parsed = num.tryParse(normalized);
    if (parsed == null) return const ValidationError(ValidationCode.invalidNumber);
    if (parsed < min || parsed > max) {
      return ValidationError(ValidationCode.outOfRange, min: min, max: max);
    }
    return null;
  }
}

/// The password policy shared by account activation and password change.
///
/// Both screens show a SUBSET of these rules in their UI (activation shows
/// length/upper/digit, password change adds special), but evaluation always
/// runs through this one implementation so the rules can never drift.
class PasswordPolicy {
  PasswordPolicy._();

  static const int minLength = 8;

  static final RegExp _upper = RegExp(r'[A-Z]');
  static final RegExp _digit = RegExp(r'[0-9]');
  static final RegExp _special = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  static bool hasMinLength(String v) => v.length >= minLength;
  static bool hasUppercase(String v) => _upper.hasMatch(v);
  static bool hasDigit(String v) => _digit.hasMatch(v);
  static bool hasSpecial(String v) => _special.hasMatch(v);

  /// 0–4: one point per satisfied rule.
  static int score(String v) {
    var s = 0;
    if (hasMinLength(v)) s++;
    if (hasUppercase(v)) s++;
    if (hasDigit(v)) s++;
    if (hasSpecial(v)) s++;
    return s;
  }

  static bool matchesConfirm(String password, String confirm) =>
      confirm.isNotEmpty && password == confirm;

  /// Returns the first violated rule (in display order) or null when valid.
  /// [requireSpecial] distinguishes the stricter password-change policy from
  /// the activation policy.
  static ValidationCode? firstFailure(String password, {bool requireSpecial = false}) {
    if (!hasMinLength(password)) return ValidationCode.tooShort;
    if (!hasUppercase(password)) return ValidationCode.missingUppercase;
    if (!hasDigit(password)) return ValidationCode.missingDigit;
    if (requireSpecial && !hasSpecial(password)) return ValidationCode.missingSpecial;
    return null;
  }
}
