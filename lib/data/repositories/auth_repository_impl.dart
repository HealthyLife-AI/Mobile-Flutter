import '../../core/errors/app_exception.dart';
import '../../core/errors/exception_mapper.dart';
import '../../core/errors/result.dart';
import '../../core/network/token_refresh_coordinator.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/push_registrar.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/session_local_data_source.dart';
import '../models/auth_dto.dart';

/// [AuthRepository] over the HTTP API and the encrypted session store.
///
/// Every method returns a [Result] and never throws. Token pairs are saved as
/// soon as the server returns them, because refresh tokens are single use.
///
/// After every network call the stored session is read again rather than
/// reused from before the call. A refresh can rotate the tokens while a
/// request is in flight, and writing back an older copy would revoke them.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SessionLocalDataSource local,
    required TokenRefreshCoordinator coordinator,
    required PushRegistrar push,
  })  : _remote = remote,
        _local = local,
        _coordinator = coordinator,
        _push = push;

  final AuthRemoteDataSource _remote;
  final SessionLocalDataSource _local;
  final TokenRefreshCoordinator _coordinator;
  final PushRegistrar _push;

  @override
  Future<Result<StoredSession?>> readSession() =>
      guard(_local.read, context: 'AuthRepository.readSession');

  @override
  Future<Result<StoredSession>> signIn({
    required String username,
    required String password,
  }) =>
      guard(() async {
        final signedIn = AuthMapper.signedInFromJson(
          await _remote.login(username: username, password: password),
        );
        final previous = await _local.read();
        final session = StoredSession(
          tokens: signedIn.tokens,
          user: signedIn.user,
          // Onboarding belongs to the patient, not the phone. A different
          // patient signing in on the same device starts the wizard again.
          onboardingCompleted: previous != null &&
              previous.user.id == signedIn.user.id &&
              previous.onboardingCompleted,
        );
        await _local.save(session);
        return session;
      }, context: 'AuthRepository.signIn');

  @override
  Future<Result<void>> refreshTokens() => guard(() async {
        await _coordinator.recover();
      }, context: 'AuthRepository.refreshTokens');

  @override
  Future<Result<PatientUser>> refreshMe() => guard(() async {
        final user = AuthMapper.userFromJson(await _remote.me());
        final latest = await _local.read();
        if (latest == null) {
          throw const UnauthorizedException('Not signed in', statusCode: 401);
        }
        await _local.save(latest.copyWith(user: user));
        return user;
      }, context: 'AuthRepository.refreshMe');

  @override
  Future<Result<ConsentStatus>> getConsent() => guard(
        () async => AuthMapper.consentFromJson(await _remote.consent()),
        context: 'AuthRepository.getConsent',
      );

  @override
  Future<Result<ConsentStatus>> acceptConsent(String version) => guard(
        () async =>
            AuthMapper.consentFromJson(await _remote.acceptConsent(version)),
        context: 'AuthRepository.acceptConsent',
      );

  @override
  Future<Result<PatientUser>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      guard(() async {
        final signedIn = AuthMapper.signedInFromJson(
          await _remote.changePassword(
            currentPassword: currentPassword,
            newPassword: newPassword,
          ),
        );
        // The server has ended every other session, and this device's old
        // refresh token is revoked. Store the new pair before anything else.
        final previous = await _local.read();
        await _local.save(StoredSession(
          tokens: signedIn.tokens,
          user: signedIn.user,
          onboardingCompleted: previous?.onboardingCompleted ?? false,
        ));
        return signedIn.user;
      }, context: 'AuthRepository.changePassword');

  @override
  Future<Result<void>> deleteAccount({required String password}) =>
      guard(() async {
        await _remote.deleteAccount(password);
        // The account is gone on the server. A local clear that fails must not
        // turn a finished deletion into an error; the cleared memory copy
        // already signs the patient out.
        try {
          await _local.clear();
        } on AppException {
          // Retried on the next launch when the stale entry is read.
        }
      }, context: 'AuthRepository.deleteAccount');

  @override
  Future<Result<void>> signOut() => guard(() async {
        try {
          final current = await _local.read();
          // Push first, while the access token still works (API guide 2.5).
          await _push.stop();
          final refresh = current?.tokens.refreshToken;
          if (refresh != null) {
            try {
              await _remote.logout(refresh);
            } on AppException {
              // Unreachable server: the local sign-out still completes.
            }
          }
        } finally {
          await _local.clear();
        }
      }, context: 'AuthRepository.signOut');

  @override
  Future<Result<void>> markOnboardingCompleted() => guard(() async {
        final current = await _local.read();
        if (current == null || current.onboardingCompleted) return;
        await _local.save(current.copyWith(onboardingCompleted: true));
      }, context: 'AuthRepository.markOnboardingCompleted');
}
