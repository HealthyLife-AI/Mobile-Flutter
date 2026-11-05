import '../../core/errors/result.dart';
import '../entities/auth_entities.dart';

/// Sign-in, session and account contract (API guide sections 2, 3, 4, 13).
///
/// Failures are returned as `Failed(ApiFailure)` with the server `code`, so
/// presentation can branch on `follow_up_ended`, `consent_version_mismatch`,
/// a 423 lock, and so on.
abstract interface class AuthRepository {
  /// The stored session, read locally (no network). Null when signed out.
  Future<Result<StoredSession?>> readSession();

  /// `POST /auth/login`. Stores the new session on success.
  Future<Result<StoredSession>> signIn({
    required String username,
    required String password,
  });

  /// `POST /auth/refresh` through the single-flight coordinator.
  Future<Result<void>> refreshTokens();

  /// `GET /auth/me`. Updates the cached user.
  Future<Result<PatientUser>> refreshMe();

  /// `GET /me/consent`.
  Future<Result<ConsentStatus>> getConsent();

  /// `POST /me/consent` with the version the patient was shown.
  Future<Result<ConsentStatus>> acceptConsent(String version);

  /// `PUT /me/password`. Stores the new token pair (every other session ends).
  Future<Result<PatientUser>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// `DELETE /me/account` (irreversible). Clears the local session on success.
  Future<Result<void>> deleteAccount({required String password});

  /// `POST /auth/logout`, then clears the local session. Always clears
  /// locally, even when the server cannot be reached.
  Future<Result<void>> signOut();

  /// Marks the on-device onboarding wizard as finished.
  Future<Result<void>> markOnboardingCompleted();
}
