import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/storage/storage_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

/// Local session persistence behind the [AuthRepository] contract.
///
/// No real backend exists yet: `activate` records the session locally after
/// a simulated round-trip. When `POST /invites/{token}/activate` lands, add
/// an HTTP data source here — the repository contract will not change.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._storage, {this.simulatedLatency = const Duration(milliseconds: 500)});

  final StorageService _storage;
  final Duration simulatedLatency;

  @override
  Future<Result<AuthSession>> getSession() => guard(
        () async {
          final raw = await _storage.readMap(StorageKeys.session);
          if (raw == null) return AuthSession.empty;
          return AuthSession.fromJson(raw) ?? AuthSession.empty;
        },
        context: 'AuthRepository.getSession',
      );

  @override
  Future<Result<AuthSession>> activate({required String password}) => guard(
        () async {
          await Future<void>.delayed(simulatedLatency); // simulated network
          final prior = await _readSession();
          // Idempotent: re-activating an already-activated invite must not
          // rewind an onboarding wizard that already finished.
          final session = prior.activated
              ? prior
              : AuthSession(
                  activated: true,
                  onboardingCompleted: false,
                  activatedAt: DateTime.now(),
                );
          await _storage.writeMap(StorageKeys.session, session.toJson());
          return session;
        },
        context: 'AuthRepository.activate',
      );

  @override
  Future<Result<AuthSession>> completeOnboarding() => guard(
        () async {
          final current = await _readSession();
          final updated = current.copyWith(onboardingCompleted: true);
          await _storage.writeMap(StorageKeys.session, updated.toJson());
          return updated;
        },
        context: 'AuthRepository.completeOnboarding',
      );

  @override
  Future<Result<void>> logout() => guard(
        () async {
          await _storage.remove(StorageKeys.session);
          // Device preferences (theme/language) deliberately survive logout;
          // user data caches would be cleared here too once they exist.
        },
        context: 'AuthRepository.logout',
      );

  Future<AuthSession> _readSession() async {
    final raw = await _storage.readMap(StorageKeys.session);
    if (raw == null) return AuthSession.empty;
    return AuthSession.fromJson(raw) ?? AuthSession.empty;
  }
}
