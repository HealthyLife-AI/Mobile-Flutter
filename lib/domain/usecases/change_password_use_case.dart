import '../../core/errors/failure.dart';
import '../../core/errors/result.dart';
import '../../core/validation/validators.dart';
import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

/// Checks a password change on the device, then calls `PUT /me/password`.
///
/// The device checks use the same server policy (8+ characters, upper case,
/// lower case, a digit). The server is still the final judge and its 422 is
/// shown when it disagrees.
class ChangePasswordUseCase {
  ChangePasswordUseCase(this._auth);

  final AuthRepository _auth;

  Future<Result<PatientUser>> call({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (currentPassword.isEmpty) {
      return const Failed(ValidationFailure(
          fieldErrors: {'current_password': 'validation.required'}));
    }
    final failure = PasswordPolicy.firstFailure(newPassword);
    if (failure != null) {
      return Failed(ValidationFailure(
          fieldErrors: {'password': 'validation.${failure.name}'}));
    }
    if (!PasswordPolicy.matchesConfirm(newPassword, confirmPassword)) {
      return const Failed(
          ValidationFailure(fieldErrors: {'confirm': 'validation.mismatch'}));
    }
    return _auth.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
