import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/core/network/session_events.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';
import 'package:healthylife_ai/domain/repositories/auth_repository.dart';
import 'package:healthylife_ai/domain/repositories/preferences_sync.dart';
import 'package:healthylife_ai/domain/repositories/push_registrar.dart';
import 'package:healthylife_ai/domain/usecases/change_password_use_case.dart';
import 'package:healthylife_ai/domain/usecases/sign_in_use_case.dart';
import 'package:healthylife_ai/l10n/l10n.dart';
import 'package:healthylife_ai/presentation/bloc/auth/auth_cubit.dart';
import 'package:healthylife_ai/presentation/screens/delete_account_screen.dart';
import 'package:healthylife_ai/presentation/widgets/confirm_action_sheet.dart';

/// The app's default language. The messages are checked against it.
final AppLocalizations ar = lookupAppLocalizations(const Locale('ar'));

/// Only `deleteAccount` is used here. The answer is set by each test.
class _FakeAuth implements AuthRepository {
  Result<void> deleteResult = Success<void>(null);
  int deleteCalls = 0;
  String? lastPassword;

  @override
  Future<Result<void>> deleteAccount({required String password}) async {
    deleteCalls++;
    lastPassword = password;
    return deleteResult;
  }

  @override
  Future<Result<StoredSession?>> readSession() =>
      throw UnimplementedError('not used by this test');

  @override
  Future<Result<StoredSession>> signIn({
    required String username,
    required String password,
  }) =>
      throw UnimplementedError('not used by this test');

  @override
  Future<Result<void>> refreshTokens() =>
      throw UnimplementedError('not used by this test');

  @override
  Future<Result<PatientUser>> refreshMe() =>
      throw UnimplementedError('not used by this test');

  @override
  Future<Result<ConsentStatus>> getConsent() =>
      throw UnimplementedError('not used by this test');

  @override
  Future<Result<ConsentStatus>> acceptConsent(String version) =>
      throw UnimplementedError('not used by this test');

  @override
  Future<Result<PatientUser>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      throw UnimplementedError('not used by this test');

  @override
  Future<Result<void>> signOut() =>
      throw UnimplementedError('not used by this test');

  @override
  Future<Result<void>> markOnboardingCompleted() =>
      throw UnimplementedError('not used by this test');
}

class _FakePush implements PushRegistrar {
  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}

class _FakePreferences implements PreferencesSync {
  @override
  Future<void> sync() async {}

  @override
  Future<void> syncIfZoneChanged() async {}
}

/// Shows the screen in Arabic, with a real [AuthCubit] over [auth].
Future<AuthCubit> pumpScreen(WidgetTester tester, _FakeAuth auth) async {
  final cubit = AuthCubit(
    auth: auth,
    signIn: SignInUseCase(auth),
    changePassword: ChangePasswordUseCase(auth),
    push: _FakePush(),
    preferences: _FakePreferences(),
    events: SessionEvents(),
  );
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthCubit>.value(
        value: cubit,
        child: const DeleteAccountScreen(),
      ),
    ),
  );
  return cubit;
}

Finder get deleteButton =>
    find.widgetWithText(ElevatedButton, ar.accountDeleteCta);

/// Types [password], presses delete and confirms in the sheet.
Future<void> deleteWith(WidgetTester tester, String password) async {
  await tester.enterText(find.byType(TextField), password);
  await tester.pump();
  await tester.tap(deleteButton);
  await tester.pumpAndSettle(); // the confirmation sheet opens
  await tester.tap(find.descendant(
    of: find.byType(ConfirmActionSheet),
    matching: find.byType(ElevatedButton),
  ));
  // Not pumpAndSettle: after success the screen keeps its spinner, because
  // the router replaces it in the app.
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('delete stays off until a password is typed', (tester) async {
    final auth = _FakeAuth();
    await pumpScreen(tester, auth);

    expect(tester.widget<ElevatedButton>(deleteButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'secret-pass');
    await tester.pump();

    expect(tester.widget<ElevatedButton>(deleteButton).onPressed, isNotNull);
    expect(auth.deleteCalls, 0);
  });

  testWidgets('cancelling the confirmation sends nothing', (tester) async {
    final auth = _FakeAuth();
    await pumpScreen(tester, auth);

    await tester.enterText(find.byType(TextField), 'secret-pass');
    await tester.pump();
    await tester.tap(deleteButton);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
      of: find.byType(ConfirmActionSheet),
      matching: find.byType(TextButton),
    ));
    await tester.pumpAndSettle();

    expect(auth.deleteCalls, 0);
    expect(find.byType(ConfirmActionSheet), findsNothing);
  });

  testWidgets(
      'a wrong password (422) is shown under the field and the patient '
      'stays signed in', (tester) async {
    final auth = _FakeAuth()
      ..deleteResult = Failed(const ApiFailure(statusCode: 422));
    final cubit = await pumpScreen(tester, auth);

    await deleteWith(tester, 'wrong-pass');

    expect(auth.deleteCalls, 1);
    expect(auth.lastPassword, 'wrong-pass');
    expect(find.text(ar.accountDeleteWrongPassword), findsOneWidget);
    expect(cubit.state.status, isNot(AuthStatus.signedOut));
    // The button comes back, so the patient can try again.
    expect(tester.widget<ElevatedButton>(deleteButton).onPressed, isNotNull);
  });

  testWidgets('too many attempts (429) shows the rate-limit message',
      (tester) async {
    final auth = _FakeAuth()
      ..deleteResult = Failed(const ApiFailure(statusCode: 429));
    await pumpScreen(tester, auth);

    await deleteWith(tester, 'secret-pass');

    expect(find.text(ar.loginErrorRateLimited), findsOneWidget);
  });

  testWidgets('no connection shows the offline message', (tester) async {
    final auth = _FakeAuth()..deleteResult = Failed(const NetworkFailure());
    await pumpScreen(tester, auth);

    await deleteWith(tester, 'secret-pass');

    expect(find.text(ar.commonOfflineBody), findsOneWidget);
  });

  testWidgets('any other failure shows the generic message', (tester) async {
    final auth = _FakeAuth()
      ..deleteResult = Failed(const ServerFailure(statusCode: 500));
    await pumpScreen(tester, auth);

    await deleteWith(tester, 'secret-pass');

    expect(find.text(ar.commonErrorBody), findsOneWidget);
  });

  testWidgets('a deleted account signs out and shows no error', (tester) async {
    final auth = _FakeAuth();
    final cubit = await pumpScreen(tester, auth);

    await deleteWith(tester, 'secret-pass');

    expect(auth.deleteCalls, 1);
    expect(cubit.state.status, AuthStatus.signedOut);
    expect(find.text(ar.accountDeleteWrongPassword), findsNothing);
    expect(find.text(ar.commonErrorBody), findsNothing);
  });
}
