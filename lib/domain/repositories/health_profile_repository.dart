import '../../core/errors/result.dart';
import '../entities/patient_health_profile_entities.dart';

/// The patient's approved health profile (API guide 11.1) and the change
/// requests they send about it (11.2, 11.3).
abstract interface class HealthProfileRepository {
  Future<Result<PatientHealthProfile>> getProfile();

  /// Sends a change request. It stays pending until the nutritionist decides.
  Future<Result<void>> propose(ChangeRequestDraft draft);

  /// Withdraws a pending request.
  Future<Result<void>> withdraw(int proposalId);
}
