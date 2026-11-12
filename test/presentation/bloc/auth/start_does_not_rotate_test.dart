import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/di/app_dependencies.dart';
import 'package:healthylife_ai/core/network/auth_tokens.dart';
import 'package:healthylife_ai/domain/entities/auth_entities.dart';
import 'package:healthylife_ai/presentation/bloc/auth/auth_cubit.dart';

import '../../../helpers/scripted_api.dart';

/// A refresh token is single use, and re-using one ends every session of the
/// patient. Start-up therefore does not rotate it: only a rejected access
/// token does (the network layer, see auth_interceptor_test.dart).
void main() {
  test('starting with a stored session reads the user and refreshes nothing',
      () async {
    final api = ScriptedApi({
      'GET auth/me': {'id': 5, 'name': 'Sara', 'role': 'client'},
      'GET me/consent': {'current_version': '1', 'accepted_version': '1'},
    });
    final deps = AppDependencies.inMemory(api: api);
    await deps.session.save(const StoredSession(
      tokens: AuthTokens(accessToken: 'a', refreshToken: 'r'),
      user: PatientUser(id: 5, name: 'Sara'),
      onboardingCompleted: true,
    ));
    final cubit = AuthCubit(
      auth: deps.auth,
      signIn: deps.signIn,
      changePassword: deps.changePassword,
      push: deps.push,
      preferences: deps.preferences,
      events: deps.sessionEvents,
      hasReadings: deps.hasMeasurementHistory,
    );
    addTearDown(cubit.close);

    await cubit.start();

    expect(api.to('GET', 'auth/me'), hasLength(1));
    expect(api.to('POST', 'auth/refresh'), isEmpty);
    expect(cubit.state.user?.name, 'Sara');
    expect((await deps.session.read())?.tokens.refreshToken, 'r',
        reason: 'the stored refresh token is untouched');
  });
}
