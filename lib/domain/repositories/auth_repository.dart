import '../../core/errors/result.dart';
import '../entities/auth_session.dart';

/// Session lifecycle for the invite-based flow (no username login exists).
abstract interface class AuthRepository {
  /// Current persisted session, or [AuthSession.empty].
  Future<Result<AuthSession>> getSession();

  /// Marks the invite as activated with the chosen password (mock: the
  /// real implementation will call `POST /invites/{token}/activate`).
  Future<Result<AuthSession>> activate({required String password});

  /// Called when the onboarding wizard (measurements → health →
  /// notifications) finishes.
  Future<Result<AuthSession>> completeOnboarding();

  /// Clears the local session (and would revoke the server session once a
  /// backend exists).
  Future<Result<void>> logout();
}
