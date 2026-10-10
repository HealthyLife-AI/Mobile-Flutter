import '../../core/errors/failure.dart';
import '../../core/errors/result.dart';
import '../../core/validation/validators.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Validates the chosen password against the shared [PasswordPolicy], then
/// asks the repository to activate the invite session.
class ActivateAccountUseCase {
  ActivateAccountUseCase(this._auth);

  final AuthRepository _auth;

  Future<Result<AuthSession>> call({required String password, required String confirmPassword}) async {
    final failure = PasswordPolicy.firstFailure(password);
    if (failure != null) {
      return Failed(ValidationFailure(fieldErrors: {'password': 'validation.${failure.name}'}));
    }
    if (!PasswordPolicy.matchesConfirm(password, confirmPassword)) {
      return const Failed(ValidationFailure(fieldErrors: {'confirm': 'validation.mismatch'}));
    }
    return _auth.activate(password: password);
  }
}
