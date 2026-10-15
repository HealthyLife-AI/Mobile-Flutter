import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/data/services/flutter_device_timezone.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_timezone');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// Makes the platform answer `getLocalTimezone` with [reply].
  void platformAnswers(Object? Function() reply) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method != 'getLocalTimezone') return null;
      return reply();
    });
  }

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('FlutterDeviceTimezone (API guide 10.5)', () {
    test('answers the IANA name the platform reports', () async {
      platformAnswers(() => 'Asia/Hebron');

      expect(await const FlutterDeviceTimezone().ianaName(), 'Asia/Hebron');
    });

    test('reads the identifier when the platform answers with a map', () async {
      platformAnswers(() => {'identifier': 'Europe/Berlin'});

      expect(await const FlutterDeviceTimezone().ianaName(), 'Europe/Berlin');
    });

    test('a platform that answers nothing makes the read fail', () async {
      platformAnswers(() => null);

      await expectLater(
        const FlutterDeviceTimezone().ianaName(),
        throwsArgumentError,
      );
    });
  });
}
