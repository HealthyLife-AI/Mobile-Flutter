import '../../core/errors/result.dart';
import '../../core/errors/failure.dart';
import '../entities/auth_entities.dart';
import '../repositories/auth_repository.dart';

/// Checks the sign-in form, then calls the repository.
///
/// Only presence is checked. The password is passed through exactly as typed:
/// the sign-in screen does not apply the strength policy (API guide 3.1), and
/// the username is only trimmed. The server normalises case and digits.
class SignInUseCase {
  SignInUseCase(this._auth);

  final AuthRepository _auth;

  Future<Result<StoredSession>> call({
    required String username,
    required String password,
  }) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      return const Failed(
          ValidationFailure(fieldErrors: {'username': 'validation.required'}));
    }
    if (password.isEmpty) {
      return const Failed(
          ValidationFailure(fieldErrors: {'password': 'validation.required'}));
    }
    return _auth.signIn(username: trimmed, password: password);
  }
}
