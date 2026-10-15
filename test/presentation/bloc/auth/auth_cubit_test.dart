import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/core/network/auth_tokens.dart';
import 'package:healthylife_ai/core/network/session_events.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';
import 'package:healthylife_ai/domain/repositories/auth_repository.dart';
import 'package:healthylife_ai/domain/repositories/preferences_sync.dart';
import 'package:healthylife_ai/domain/repositories/push_registrar.dart';
import 'package:healthylife_ai/domain/usecases/change_password_use_case.dart';
import 'package:healthylife_ai/domain/usecases/sign_in_use_case.dart';
import 'package:healthylife_ai/presentation/bloc/auth/auth_cubit.dart';

/// Every answer the cubit can get from the repository is set by the test.
class _FakeAuth implements AuthRepository {
  Result<StoredSession?> session = Success<StoredSession?>(null);
  Result<void> refresh = Success<void>(null);
  Result<PatientUser> me = Failed(const UnexpectedFailure());
  Result<ConsentStatus> consent = Success(ConsentStatus(isRequired: false));
  Result<StoredSession> signInResult = Failed(const UnexpectedFailure());
  Result<ConsentStatus> acceptResult =
      Success(ConsentStatus(isRequired: false));
  Result<PatientUser> changePasswordResult = Failed(const UnexpectedFailure());
  Result<void> deleteResult = Success<void>(null);
  Result<void> signOutResult = Success<void>(null);
  Result<void> markResult = Success<void>(null);

  int signInCalls = 0;
  int signOutCalls = 0;
  int markCalls = 0;

  @override
  Future<Result<StoredSession?>> readSession() async => session;

  @override
  Future<Result<StoredSession>> signIn({
    required String username,
    required String password,
  }) async {
    signInCalls++;
    return signInResult;
  }

  @override
  Future<Result<void>> refreshTokens() async => refresh;

  @override
  Future<Result<PatientUser>> refreshMe() async => me;

  @override
  Future<Result<ConsentStatus>> getConsent() async => consent;

  @override
  Future<Result<ConsentStatus>> acceptConsent(String version) async =>
      acceptResult;

  @override
  Future<Result<PatientUser>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async =>
      changePasswordResult;

  @override
  Future<Result<void>> deleteAccount({required String password}) async =>
      deleteResult;

  @override
  Future<Result<void>> signOut() async {
    signOutCalls++;
    return signOutResult;
  }

  @override
  Future<Result<void>> markOnboardingCompleted() async {
    markCalls++;
    return markResult;
  }
}

class _FakePush implements PushRegistrar {
  int starts = 0;
  int stops = 0;

  @override
  Future<void> start() async {
    starts++;
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}

class _FakePreferences implements PreferencesSync {
  int syncs = 0;

  @override
  Future<void> sync() async {
    syncs++;
  }

  @override
  Future<void> syncIfZoneChanged() async {}
}

class _Harness {
  _Harness()
      : auth = _FakeAuth(),
        push = _FakePush(),
        preferences = _FakePreferences(),
        events = SessionEvents() {
    cubit = AuthCubit(
      auth: auth,
      signIn: SignInUseCase(auth),
      changePassword: ChangePasswordUseCase(auth),
      push: push,
      preferences: preferences,
      events: events,
      hasReadings: () {
        readingChecks++;
        return hasReadings();
      },
    );
  }

  final _FakeAuth auth;
  final _FakePush push;
  final _FakePreferences preferences;
  final SessionEvents events;
  late final AuthCubit cubit;

  /// What the server says about the patient's readings. None by default.
  Future<bool> Function() hasReadings = () async => false;
  int readingChecks = 0;
}

StoredSession storedSession({bool onboarded = true, bool temporary = false}) =>
    StoredSession(
      tokens: const AuthTokens(accessToken: 'a', refreshToken: 'r'),
      user: PatientUser(
        id: 31,
        name: 'Sara',
        username: 'sara.k',
        passwordIsTemporary: temporary,
      ),
      onboardingCompleted: onboarded,
    );

ConsentStatus consentRequiring(String version) =>
    ConsentStatus(isRequired: true, currentVersion: version);

/// Lets the unawaited push and preference calls finish.
Future<void> flush() => Future<void>.delayed(Duration.zero);

/// Signs the harness in as a patient who is already on the app shell.
Future<void> startSignedIn(_Harness h, {bool onboarded = true}) async {
  final session = storedSession(onboarded: onboarded);
  h.auth.session = Success<StoredSession?>(session);
  h.auth.me = Success(session.user);
  await h.cubit.start();
}

void main() {
  late _Harness h;

  setUp(() {
    h = _Harness();
  });

  tearDown(() async {
    await h.cubit.close();
  });

  group('start-up (API guide 2.1)', () {
    test('no stored session goes to sign-in without a notice', () async {
      await h.cubit.start();

      expect(h.cubit.state.status, AuthStatus.signedOut);
      expect(h.cubit.state.sessionEnded, isFalse);
    });

    test('a rejected refresh ends the session and says why', () async {
      h.auth.session = Success<StoredSession?>(storedSession());
      h.auth.refresh = Failed(const ApiFailure(statusCode: 401));

      await h.cubit.start();
      await flush();

      expect(h.cubit.state.status, AuthStatus.signedOut);
      expect(h.cubit.state.sessionEnded, isTrue);
      expect(h.push.starts, 0);
    });

    test('an offline start uses the cached session', () async {
      h.auth.session = Success<StoredSession?>(storedSession());
      h.auth.refresh = Failed(const NetworkFailure());

      await h.cubit.start();

      expect(h.cubit.state.status, AuthStatus.ready);
      expect(h.cubit.state.user?.name, 'Sara');
    });

    test('a patient who is consented and onboarded reaches the app', () async {
      await startSignedIn(h);
      await flush();

      expect(h.cubit.state.status, AuthStatus.ready);
      expect(h.preferences.syncs, 1);
      expect(h.push.starts, 1);
    });

    test('preferences are sent before the push token', () async {
      final order = <String>[];
      final push = _OrderedPush(order);
      final preferences = _OrderedPreferences(order);
      final auth = h.auth;
      final cubit = AuthCubit(
        auth: auth,
        signIn: SignInUseCase(auth),
        changePassword: ChangePasswordUseCase(auth),
        push: push,
        preferences: preferences,
        events: h.events,
      );
      addTearDown(cubit.close);
      final session = storedSession();
      auth.session = Success<StoredSession?>(session);
      auth.me = Success(session.user);

      await cubit.start();
      await flush();

      expect(order, ['preferences', 'push']);
    });

    test('a patient who has not finished onboarding goes to the wizard',
        () async {
      await startSignedIn(h, onboarded: false);

      expect(h.cubit.state.status, AuthStatus.onboarding);
    });

    test('required consent blocks the app and push does not start', () async {
      h.auth.session = Success<StoredSession?>(storedSession());
      h.auth.me = Success(storedSession().user);
      h.auth.consent = Success(consentRequiring('v2'));

      await h.cubit.start();
      await flush();

      expect(h.cubit.state.status, AuthStatus.consentRequired);
      expect(h.cubit.state.consent?.currentVersion, 'v2');
      expect(h.push.starts, 0);
    });

    test('follow-up ended on the consent check shows the follow-up screen',
        () async {
      h.auth.session = Success<StoredSession?>(storedSession());
      h.auth.me = Success(storedSession().user);
      h.auth.consent = Failed(ApiFailure(
        statusCode: 403,
        code: 'follow_up_ended',
        body: {
          'message': 'ended',
          'nutritionist': {
            'name': 'Dr. Ahmad',
            'whatsapp_number': '+970599123456',
          },
          'weeks_followed': 12,
        },
      ));

      await h.cubit.start();

      expect(h.cubit.state.status, AuthStatus.followUpEnded);
      expect(h.cubit.state.followUp?.nutritionistName, 'Dr. Ahmad');
      expect(h.cubit.state.followUp?.whatsappNumber, '+970599123456');
      expect(h.cubit.state.followUp?.weeksFollowed, 12);
    });
  });

  group('sign-in (API guide 3.1)', () {
    test('a wrong password keeps the sign-in screen and shows the failure',
        () async {
      await h.cubit.start(); // no stored session: sign-in is shown
      h.auth.signInResult = Failed(const ApiFailure(statusCode: 401));

      await h.cubit.signIn(username: 'sara.k', password: 'wrong');

      expect(h.cubit.state.status, AuthStatus.signedOut);
      expect(h.cubit.state.busy, isFalse);
      expect(h.cubit.state.failure, isA<ApiFailure>());
    });

    test('an empty username never reaches the server', () async {
      await h.cubit.signIn(username: '   ', password: 'anything');

      expect(h.auth.signInCalls, 0);
      expect(h.cubit.state.failure, isA<ValidationFailure>());
    });

    test('a correct sign-in routes to the app', () async {
      h.auth.signInResult = Success(storedSession());

      await h.cubit.signIn(username: 'sara.k', password: 'right');

      expect(h.cubit.state.status, AuthStatus.ready);
      expect(h.cubit.state.user?.name, 'Sara');
    });

    test('signing in again after sign-out skips the wizard when readings exist',
        () async {
      // Sign-out cleared the stored session, so its wizard flag is gone.
      h.auth.signInResult = Success(storedSession(onboarded: false));
      h.hasReadings = () async => true;

      await h.cubit.signIn(username: 'sara.k', password: 'right');

      expect(h.cubit.state.status, AuthStatus.ready);
      expect(h.cubit.state.onboardingCompleted, isTrue);
      expect(h.auth.markCalls, 1, reason: 'the flag is saved again');
    });

    test('a new patient without readings starts the wizard', () async {
      h.auth.signInResult = Success(storedSession(onboarded: false));

      await h.cubit.signIn(username: 'sara.k', password: 'right');

      expect(h.cubit.state.status, AuthStatus.onboarding);
      expect(h.auth.markCalls, 0);
    });

    test('when the readings cannot be read, the wizard shows', () async {
      h.auth.signInResult = Success(storedSession(onboarded: false));
      h.hasReadings = () async => throw StateError('offline');

      await h.cubit.signIn(username: 'sara.k', password: 'right');

      expect(h.cubit.state.status, AuthStatus.onboarding);
    });

    test('a patient already onboarded is not checked again', () async {
      h.auth.signInResult = Success(storedSession());

      await h.cubit.signIn(username: 'sara.k', password: 'right');

      expect(h.readingChecks, 0);
    });

    test('readings are not read before the policy is accepted', () async {
      h.auth.signInResult = Success(storedSession(onboarded: false));
      h.auth.consent = Success(consentRequiring('v2'));
      h.hasReadings = () async => true;

      await h.cubit.signIn(username: 'sara.k', password: 'right');

      expect(h.cubit.state.status, AuthStatus.consentRequired);
      expect(h.readingChecks, 0);

      await h.cubit.acceptConsent();

      expect(h.cubit.state.status, AuthStatus.ready);
      expect(h.readingChecks, 1);
    });
  });

  group('session events from the network stack', () {
    test('consent required mid-session returns the patient to consent',
        () async {
      await startSignedIn(h);

      h.events.emit(SessionEvent(
        SessionEventType.consentRequired,
        body: {'required': true, 'current_version': 'v2'},
      ));
      await flush();

      expect(h.cubit.state.status, AuthStatus.consentRequired);
      expect(h.cubit.state.consent?.currentVersion, 'v2');
    });

    test('consent required while signed out is ignored', () async {
      await h.cubit.start();

      h.events.emit(SessionEvent(
        SessionEventType.consentRequired,
        body: {'required': true, 'current_version': 'v2'},
      ));
      await flush();

      expect(h.cubit.state.status, AuthStatus.signedOut);
    });

    test('follow-up ended mid-session shows the follow-up screen', () async {
      await startSignedIn(h);

      h.events.emit(SessionEvent(
        SessionEventType.followUpEnded,
        body: {'message': 'ended'},
      ));
      await flush();

      expect(h.cubit.state.status, AuthStatus.followUpEnded);
      expect(h.cubit.state.followUp?.message, 'ended');
    });

    test('an expired session mid-session signs out and says why', () async {
      await startSignedIn(h);

      h.events.emit(const SessionEvent(SessionEventType.expired));
      await flush();

      expect(h.cubit.state.status, AuthStatus.signedOut);
      expect(h.cubit.state.sessionEnded, isTrue);
    });

    test('an expired event while signed out changes nothing', () async {
      await h.cubit.start();

      h.events.emit(const SessionEvent(SessionEventType.expired));
      await flush();

      expect(h.cubit.state.status, AuthStatus.signedOut);
      expect(h.cubit.state.sessionEnded, isFalse);
    });
  });

  group('account (API guide 3.5 and 13)', () {
    test('changing the password stores the updated user', () async {
      await startSignedIn(h, onboarded: true);
      h.auth.changePasswordResult =
          Success(storedSession(temporary: false).user);

      final result = await h.cubit.changePassword(
        currentPassword: 'old',
        newPassword: 'Abcdefg1',
        confirmPassword: 'Abcdefg1',
      );

      expect(result.isSuccess, isTrue);
      expect(h.cubit.state.user?.passwordIsTemporary, isFalse);
    });

    test('a weak new password is refused before the server is called',
        () async {
      final result = await h.cubit.changePassword(
        currentPassword: 'old',
        newPassword: 'short',
        confirmPassword: 'short',
      );

      expect(result.isSuccess, isFalse);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('deleting the account signs out on success', () async {
      await startSignedIn(h);

      final result = await h.cubit.deleteAccount(password: 'current');

      expect(result.isSuccess, isTrue);
      expect(h.cubit.state.status, AuthStatus.signedOut);
    });

    test('a failed deletion keeps the patient signed in', () async {
      await startSignedIn(h);
      h.auth.deleteResult = Failed(const ApiFailure(statusCode: 422));

      final result = await h.cubit.deleteAccount(password: 'wrong');

      expect(result.failureOrNull, isA<ApiFailure>());
      expect(h.cubit.state.status, AuthStatus.ready);
    });

    test('signing out returns to sign-in even when the server fails', () async {
      await startSignedIn(h);
      h.auth.signOutResult = Failed(const NetworkFailure());

      await h.cubit.signOut();

      expect(h.cubit.state.status, AuthStatus.signedOut);
      expect(h.auth.signOutCalls, 1);
    });
  });

  group('consent (API guide 4)', () {
    test('accepting the policy opens the app', () async {
      h.auth.session = Success<StoredSession?>(storedSession());
      h.auth.me = Success(storedSession().user);
      h.auth.consent = Success(consentRequiring('v1'));
      await h.cubit.start();
      h.auth.acceptResult = Success(ConsentStatus(
        isRequired: false,
        currentVersion: 'v1',
      ));

      await h.cubit.acceptConsent();

      expect(h.cubit.state.status, AuthStatus.ready);
    });

    test('a policy change during acceptance reloads the new version', () async {
      h.auth.session = Success<StoredSession?>(storedSession());
      h.auth.me = Success(storedSession().user);
      h.auth.consent = Success(consentRequiring('v1'));
      await h.cubit.start();

      h.auth.consent = Success(consentRequiring('v2'));
      h.auth.acceptResult = Failed(ApiFailure(
        statusCode: 409,
        code: 'consent_version_mismatch',
        body: {'current_version': 'v2'},
      ));

      await h.cubit.acceptConsent();

      expect(h.cubit.state.status, AuthStatus.consentRequired);
      expect(h.cubit.state.consent?.currentVersion, 'v2');
      expect(h.cubit.state.failure, isA<ApiFailure>());
    });
  });

  group('onboarding wizard', () {
    test('finishing the wizard opens the app and saves the flag', () async {
      await startSignedIn(h, onboarded: false);

      await h.cubit.completeOnboarding();

      expect(h.cubit.state.status, AuthStatus.ready);
      expect(h.auth.markCalls, 1);
    });
  });
}

class _OrderedPush implements PushRegistrar {
  _OrderedPush(this._order);

  final List<String> _order;

  @override
  Future<void> start() async {
    _order.add('push');
  }

  @override
  Future<void> stop() async {}
}

class _OrderedPreferences implements PreferencesSync {
  _OrderedPreferences(this._order);

  final List<String> _order;

  @override
  Future<void> sync() async {
    _order.add('preferences');
  }

  @override
  Future<void> syncIfZoneChanged() async {}
}
