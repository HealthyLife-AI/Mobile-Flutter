import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/services/firebase_push_registrar.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/scripted_api.dart';

class _Messaging extends Mock implements FirebaseMessaging {}

void main() {
  late ScriptedApi api;
  late _Messaging messaging;
  late List<String> order;

  setUp(() {
    order = [];
    api = ScriptedApi({
      'PUT me/fcm-token': (SentRequest _) {
        order.add('token');
        return null;
      },
    });
    messaging = _Messaging();
    when(() => messaging.getToken()).thenAnswer((_) async => 'device-token');
    when(() => messaging.onTokenRefresh)
        .thenAnswer((_) => const Stream<String>.empty());
  });

  test('the push channel exists before the token is sent (10.4)', () async {
    final registrar = FirebasePushRegistrar(
      api: api,
      messaging: () => messaging,
      prepareChannel: () async => order.add('channel'),
    );

    await registrar.start();

    expect(order, ['channel', 'token']);
    expect(api.to('PUT', 'me/fcm-token').single.body,
        {'fcm_token': 'device-token'});
  });

  test('a channel that cannot be made does not stop the registration',
      () async {
    final registrar = FirebasePushRegistrar(
      api: api,
      messaging: () => messaging,
      prepareChannel: () async => throw StateError('no plugin'),
    );

    await registrar.start();

    expect(order, ['token']);
  });
}
