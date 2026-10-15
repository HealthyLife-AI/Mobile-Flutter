import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/result.dart';
import '../../../core/network/session_events.dart';
import '../../../domain/entities/auth_entities.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/preferences_sync.dart';
import '../../../domain/repositories/push_registrar.dart';
import '../../../domain/usecases/change_password_use_case.dart';
import '../../../domain/usecases/sign_in_use_case.dart';

/// Where the patient stands. `AppRouter.destinationFor` maps each value to
/// exactly one screen, so no screen decides navigation for itself.
enum AuthStatus {
  /// Start-up has not finished reading the stored session (splash).
  unknown,

  /// No session on this device: the sign-in screen.
  signedOut,

  /// Signed in, but the current privacy policy is not accepted (API guide 4).
  consentRequired,

  /// Signed in and consented, but the post-sign-in wizard is not finished.
  onboarding,

  /// Signed in, consented and onboarded: the app shell.
  ready,

  /// The nutritionist ended follow-up (API guide 2.4). The tokens are gone.
  followUpEnded,
}

@immutable
class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.launching = true,
    this.busy = false,
    this.failure,
    this.user,
    this.consent,
    this.followUp,
    this.onboardingCompleted = false,
    this.sessionEnded = false,
  });

  final AuthStatus status;

  /// True until the splash has finished its minimum animation. The router
  /// ignores status changes until then, so the splash picks the first screen.
  final bool launching;

  /// A sign-in, consent or password request is in flight.
  final bool busy;

  /// The last user-facing failure of a sign-in, consent or password request.
  final Failure? failure;

  final PatientUser? user;

  /// The policy version to accept while [status] is `consentRequired`.
  final ConsentStatus? consent;

  /// Only while [status] is `followUpEnded`.
  final FollowUpEnded? followUp;

  final bool onboardingCompleted;

  /// True when sign-in is shown because the server ended the session. The
  /// sign-in screen then shows a short notice.
  final bool sessionEnded;

  bool get canEnterShell => status == AuthStatus.ready;

  AuthState copyWith({
    AuthStatus? status,
    bool? launching,
    bool? busy,
    Failure? failure,
    bool clearFailure = false,
    PatientUser? user,
    ConsentStatus? consent,
    bool? sessionEnded,
  }) =>
      AuthState(
        status: status ?? this.status,
        launching: launching ?? this.launching,
        busy: busy ?? this.busy,
        failure: clearFailure ? null : (failure ?? this.failure),
        user: user ?? this.user,
        consent: consent ?? this.consent,
        followUp: followUp,
        onboardingCompleted: onboardingCompleted,
        sessionEnded: sessionEnded ?? this.sessionEnded,
      );
}

/// Owns the patient's session state: start-up, sign-in, consent, the
/// post-sign-in wizard, sign-out and the session events from the network stack.
///
/// Every method completes without throwing. A failed sign-in, consent or password
/// request is kept in [AuthState.failure] for the screen to show.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository auth,
    required SignInUseCase signIn,
    required ChangePasswordUseCase changePassword,
    required PushRegistrar push,
    required PreferencesSync preferences,
    required SessionEvents events,
    Future<bool> Function()? hasReadings,
  })  : _auth = auth,
        _signIn = signIn,
        _changePassword = changePassword,
        _push = push,
        _preferences = preferences,
        _hasReadings = hasReadings ?? _noReadings,
        super(const AuthState()) {
    _eventsSub = events.stream.listen(_onSessionEvent);
  }

  final AuthRepository _auth;
  final SignInUseCase _signIn;
  final ChangePasswordUseCase _changePassword;
  final PushRegistrar _push;
  final PreferencesSync _preferences;

  /// Whether the patient already has readings on the server. The wizard takes
  /// the first reading, so a patient with readings has been through it, on
  /// this phone or another, and goes straight to the app. Signing out clears
  /// the stored session and its wizard flag, so this is what remembers it.
  final Future<bool> Function() _hasReadings;

  static Future<bool> _noReadings() async => false;
  late final StreamSubscription<SessionEvent> _eventsSub;

  @override
  Future<void> close() async {
    await _eventsSub.cancel();
    return super.close();
  }

  // ───────────────────────── start-up (API guide 2.1) ─────────────────────────

  /// Restores the stored session, rotates the tokens, loads the user and checks
  /// consent. Offline, the cached session is used. The splash then calls
  /// [finishLaunch] and opens the screen for the resulting status.
  Future<void> start() async {
    final stored = await _auth.readSession();
    if (isClosed) return;
    final session = stored.valueOrNull;
    if (session == null) {
      _moveTo(AuthStatus.signedOut);
      return;
    }

    final refreshed = await _auth.refreshTokens();
    if (isClosed) return;
    final refreshFailure = refreshed.failureOrNull;
    if (refreshFailure != null) {
      if (_isSessionRejected(refreshFailure)) {
        _moveTo(AuthStatus.signedOut, sessionEnded: true);
      } else {
        // Offline or server down: run on the cached session. The next data
        // call reports a consent or follow-up change if one happened meanwhile.
        await _routeSignedIn(
          user: session.user,
          onboardingCompleted: session.onboardingCompleted,
        );
      }
      return;
    }

    final me = await _auth.refreshMe();
    if (isClosed) return;
    final meFailure = me.failureOrNull;
    final followUp = _followUpBody(meFailure);
    if (followUp != null) {
      _showFollowUp(followUp);
      return;
    }
    if (meFailure != null && _isSessionRejected(meFailure)) {
      _moveTo(AuthStatus.signedOut, sessionEnded: true);
      return;
    }

    final consent = await _auth.getConsent();
    if (isClosed) return;
    final consentFollowUp = _followUpBody(consent.failureOrNull);
    if (consentFollowUp != null) {
      _showFollowUp(consentFollowUp);
      return;
    }
    await _routeSignedIn(
      user: me.valueOrNull ?? session.user,
      onboardingCompleted: session.onboardingCompleted,
      consent: consent.valueOrNull,
    );
  }

  /// Called by the splash once its minimum duration has passed.
  void finishLaunch() {
    if (!isClosed) emit(state.copyWith(launching: false));
  }

  // ───────────────────────── sign-in (API guide 3.1) ─────────────────────────

  Future<void> signIn({
    required String username,
    required String password,
  }) async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, clearFailure: true, sessionEnded: false));
    final result = await _signIn(username: username, password: password);
    if (isClosed) return;

    switch (result) {
      case Success<StoredSession>(:final value):
        final consent = await _auth.getConsent();
        if (isClosed) return;
        final followUp = _followUpBody(consent.failureOrNull);
        if (followUp != null) {
          _showFollowUp(followUp);
          return;
        }
        await _routeSignedIn(
          user: value.user,
          onboardingCompleted: value.onboardingCompleted,
          consent: consent.valueOrNull,
        );
      case Failed<StoredSession>(:final failure):
        final followUp = _followUpBody(failure);
        if (followUp != null) {
          _showFollowUp(followUp);
          return;
        }
        emit(state.copyWith(busy: false, failure: failure));
    }
  }

  // ───────────────────────── consent (API guide 4) ─────────────────────────

  /// Accepts the policy version the screen is showing. A 409 means the policy
  /// changed meanwhile: the new version is loaded and shown instead.
  Future<void> acceptConsent() async {
    if (state.busy) return;
    final version = state.consent?.currentVersion;
    if (version == null) {
      await _reloadConsent();
      return;
    }
    emit(state.copyWith(busy: true, clearFailure: true));
    final result = await _auth.acceptConsent(version);
    if (isClosed) return;

    switch (result) {
      case Success<ConsentStatus>(:final value):
        await _routeSignedIn(
          user: state.user,
          onboardingCompleted: state.onboardingCompleted,
          consent: value,
        );
      case Failed<ConsentStatus>(:final failure):
        final followUp = _followUpBody(failure);
        if (followUp != null) {
          _showFollowUp(followUp);
          return;
        }
        if (failure is ApiFailure &&
            failure.code == 'consent_version_mismatch') {
          final fresh = await _auth.getConsent();
          if (isClosed) return;
          emit(state.copyWith(
            busy: false,
            consent: fresh.valueOrNull ?? state.consent,
            failure: failure,
          ));
          return;
        }
        emit(state.copyWith(busy: false, failure: failure));
    }
  }

  Future<void> _reloadConsent() async {
    final result = await _auth.getConsent();
    if (isClosed) return;
    final followUp = _followUpBody(result.failureOrNull);
    if (followUp != null) {
      _showFollowUp(followUp);
      return;
    }
    final consent = result.valueOrNull;
    if (consent == null) {
      emit(state.copyWith(busy: false, failure: result.failureOrNull));
      return;
    }
    if (!consent.isRequired) {
      await _routeSignedIn(
        user: state.user,
        onboardingCompleted: state.onboardingCompleted,
        consent: consent,
      );
      return;
    }
    emit(state.copyWith(busy: false, consent: consent, clearFailure: true));
  }

  // ───────────────────────── onboarding wizard ─────────────────────────

  /// Ends the post-sign-in wizard and opens the shell. The shell opens even if
  /// the flag cannot be saved: the worst case is the wizard again on next launch.
  Future<void> completeOnboarding() async {
    if (state.status != AuthStatus.onboarding) return;
    final user = state.user;
    final consent = state.consent;
    await _auth.markOnboardingCompleted();
    if (isClosed) return;
    _moveTo(
      AuthStatus.ready,
      user: user,
      consent: consent,
      onboardingCompleted: true,
    );
  }

  // ───────────────────────── account (API guide 3.5, 13) ─────────────────────────

  Future<Result<PatientUser>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final result = await _changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
    if (result case Success<PatientUser>(:final value)) {
      if (!isClosed) emit(state.copyWith(user: value));
    }
    return result;
  }

  Future<Result<void>> deleteAccount({required String password}) async {
    final result = await _auth.deleteAccount(password: password);
    if (result.isSuccess) _moveTo(AuthStatus.signedOut);
    return result;
  }

  /// Ends the session on this device. Always completes, even offline.
  Future<void> signOut() async {
    await _auth.signOut();
    _moveTo(AuthStatus.signedOut);
  }

  // ───────────────────────── session events from the network stack ─────────────

  void _onSessionEvent(SessionEvent event) {
    switch (event.type) {
      case SessionEventType.expired:
        if (state.status == AuthStatus.signedOut ||
            state.status == AuthStatus.unknown) {
          return;
        }
        _moveTo(AuthStatus.signedOut, sessionEnded: true);
      case SessionEventType.followUpEnded:
        _showFollowUp(event.body);
      case SessionEventType.consentRequired:
        if (state.status == AuthStatus.signedOut) return;
        _moveTo(
          AuthStatus.consentRequired,
          user: state.user,
          consent: ConsentStatus.fromJson(event.body),
          onboardingCompleted: state.onboardingCompleted,
        );
    }
  }

  // ───────────────────────── helpers ─────────────────────────

  /// Moves to a signed-in status. Push registration starts only here, once the
  /// patient may use the app (API guide 2.1, step 5).
  ///
  /// The wizard is for a patient's first entry only: one whose readings are
  /// already on the server goes to the app, and the flag is saved again.
  Future<void> _routeSignedIn({
    PatientUser? user,
    required bool onboardingCompleted,
    ConsentStatus? consent,
  }) async {
    if (consent != null && consent.isRequired) {
      _moveTo(
        AuthStatus.consentRequired,
        user: user,
        consent: consent,
        onboardingCompleted: onboardingCompleted,
      );
      return;
    }
    var completed = onboardingCompleted;
    if (!completed && await _returningPatient()) {
      completed = true;
      await _auth.markOnboardingCompleted();
    }
    if (isClosed) return;
    _moveTo(
      completed ? AuthStatus.ready : AuthStatus.onboarding,
      user: user,
      consent: consent,
      onboardingCompleted: completed,
    );
    unawaited(_startNotifications());
  }

  /// No answer (offline, server down) counts as "not known": the wizard shows,
  /// as it did before this check existed.
  Future<bool> _returningPatient() async {
    try {
      return await _hasReadings();
    } on Object {
      return false;
    }
  }

  /// API guide 2.1: the preferences (step 4) go before the push token (step 5).
  /// Both run in the background. Every start and sign-in repeats them, so a
  /// failed attempt is retried the next time.
  Future<void> _startNotifications() async {
    await _preferences.sync();
    await _push.start();
  }

  void _showFollowUp(Map<String, dynamic> body) {
    _moveTo(
      AuthStatus.followUpEnded,
      followUp: FollowUpEnded.fromJson(body),
    );
  }

  /// Replaces the state. Each status change clears what does not belong to it.
  void _moveTo(
    AuthStatus status, {
    PatientUser? user,
    ConsentStatus? consent,
    FollowUpEnded? followUp,
    bool onboardingCompleted = false,
    bool sessionEnded = false,
  }) {
    if (isClosed) return;
    emit(AuthState(
      status: status,
      launching: state.launching,
      user: user,
      consent: consent,
      followUp: followUp,
      onboardingCompleted: onboardingCompleted,
      sessionEnded: sessionEnded,
    ));
  }

  /// The server rejected the session: the refresh token is used up or revoked.
  static bool _isSessionRejected(Failure failure) =>
      failure is UnauthorizedFailure ||
      (failure is ApiFailure && failure.statusCode == 401);

  /// The `follow_up_ended` body, or null for any other failure.
  static Map<String, dynamic>? _followUpBody(Failure? failure) =>
      failure is ApiFailure && failure.code == 'follow_up_ended'
          ? failure.body
          : null;
}
