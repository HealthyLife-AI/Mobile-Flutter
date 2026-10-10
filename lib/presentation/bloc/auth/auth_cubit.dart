import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/failure.dart';
import '../../../core/errors/result.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/activate_account_use_case.dart';

enum AuthStatus {
  /// Session state not read yet (splash).
  unknown,

  /// Invite not activated → marketing onboarding / activation flow.
  unauthenticated,

  /// Activated but onboarding wizard unfinished.
  onboarding,

  /// Activated + onboarded → app shell allowed.
  ready,
}

@immutable
class AuthState {
  const AuthState({this.status = AuthStatus.unknown, this.busy = false, this.failure});

  final AuthStatus status;

  /// True while an activation/logout request is in flight (prevents
  /// double submits at the state level).
  final bool busy;
  final Failure? failure;

  bool get canEnterShell => status == AuthStatus.ready;

  AuthState copyWith({AuthStatus? status, bool? busy, Failure? failure, bool clearFailure = false}) => AuthState(
        status: status ?? this.status,
        busy: busy ?? this.busy,
        failure: failure ?? (clearFailure ? null : this.failure),
      );
}


class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._auth, this._activateAccount) : super(const AuthState());

  final AuthRepository _auth;
  final ActivateAccountUseCase _activateAccount;

  /// Reads the persisted session once at startup (splash waits on this).
  Future<void> loadSession() async {
    final result = await _auth.getSession();
    if (isClosed) return;
    emit(state.copyWith(status: _statusFor(result.valueOrNull ?? AuthSession.empty), clearFailure: true));
  }

  /// Chooses a password for the clinic invite and activates the session.
  Future<Result<AuthSession>> activate({required String password, required String confirmPassword}) async {
    emit(state.copyWith(busy: true, clearFailure: true));
    final result = await _activateAccount(password: password, confirmPassword: confirmPassword);
    if (isClosed) return result;
    if (result case Success<AuthSession>(:final value)) {
      emit(state.copyWith(status: _statusFor(value), busy: false));
    } else {
      emit(state.copyWith(busy: false, failure: result.failureOrNull));
    }
    return result;
  }

  Future<Result<AuthSession>> completeOnboarding() async {
    final result = await _auth.completeOnboarding();
    if (isClosed) return result;
    emit(state.copyWith(status: _statusFor(result.valueOrNull ?? AuthSession.empty), clearFailure: true));
    return result;
  }

  Future<Result<void>> logout() async {
    final result = await _auth.logout();
    if (isClosed) return result;
    emit(state.copyWith(status: AuthStatus.unauthenticated, clearFailure: true));
    return result;
  }

  AuthStatus _statusFor(AuthSession session) {
    if (session.isReady) return AuthStatus.ready;
    if (session.activated) return AuthStatus.onboarding;
    return AuthStatus.unauthenticated;
  }
}
