import '../../core/errors/failure.dart';
import '../../core/errors/result.dart';
import '../../core/validation/validators.dart';

/// Validates a password change request.
///
/// There is no backend yet, so the "current password" check and the actual
/// update are simulated with a delay — the validation path (the part that
/// must not rely on the UI) is real and unit-tested. Swap the simulated
/// block for an API call when the backend exists.
class ChangePasswordUseCase {
  ChangePasswordUseCase({this.simulatedLatency = const Duration(milliseconds: 650)});

  final Duration simulatedLatency;

  Future<Result<void>> call({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.trim().isEmpty) {
      return const Failed(ValidationFailure(fieldErrors: {'current': 'validation.required'}));
    }
    final failure = PasswordPolicy.firstFailure(newPassword, requireSpecial: true);
    if (failure != null) {
      return Failed(ValidationFailure(fieldErrors: {'new': 'validation.${failure.name}'}));
    }
    if (!PasswordPolicy.matchesConfirm(newPassword, confirmPassword)) {
      return const Failed(ValidationFailure(fieldErrors: {'confirm': 'validation.mismatch'}));
    }
    await Future<void>.delayed(simulatedLatency);
    return const Success(null);
  }
}
