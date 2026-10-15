import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/data/services/notification_preferences_sync.dart';
import 'package:healthylife_ai/domain/repositories/device_timezone.dart';
import 'package:healthylife_ai/domain/repositories/settings_repository.dart';

/// Records PUT requests. Each call takes the next scripted answer: null is a
/// success, an [AppException] is thrown. Only `put` is used by the sync, so
/// the other verbs fail loudly if something starts calling them.
class _RecordingApi implements ApiClient {
  _RecordingApi([this.answers = const []]);

  final List<AppException?> answers;
  final List<String> paths = [];
  final List<Map<String, dynamic>> bodies = [];
  int _calls = 0;

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    paths.add(path);
    bodies.add(Map<String, dynamic>.from(body as Map));
    final answer = _calls < answers.length ? answers[_calls] : null;
    _calls++;
    if (answer != null) throw answer;
    return null;
  }

  @override
  Future<dynamic> get(String path,
          {Map<String, dynamic>? query, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);
}

class _FixedSettings implements SettingsRepository {
  _FixedSettings(this.locale);

  final Locale? locale;

  @override
  Future<Result<Locale?>> getLocale() async => Success<Locale?>(locale);

  @override
  Future<Result<ThemeMode>> getThemeMode() async =>
      const Success(ThemeMode.light);

  @override
  Future<Result<void>> setThemeMode(ThemeMode mode) async =>
      Success<void>(null);

  @override
  Future<Result<void>> setLocale(Locale? locale) async => Success<void>(null);
}

/// Answers the device's timezone name, or fails when [fails] is set.
class _FixedTimezone implements DeviceTimezone {
  _FixedTimezone(this.name, {this.fails = false});

  final String? name;
  final bool fails;

  @override
  Future<String?> ianaName() async {
    if (fails) throw StateError('the timezone cannot be read');
    return name;
  }
}

/// A timezone that can change, or stop being readable, between two calls.
class _ChangingTimezone implements DeviceTimezone {
  _ChangingTimezone(this.name);

  String? name;
  bool fails = false;

  @override
  Future<String?> ianaName() async {
    if (fails) throw StateError('the timezone cannot be read');
    return name;
  }
}

NotificationPreferencesSync _sync({
  required _RecordingApi api,
  Locale? locale,
  DeviceTimezone? timezone,
}) =>
    NotificationPreferencesSync(
      api: api,
      settings: _FixedSettings(locale),
      timezone: timezone ?? _FixedTimezone(null),
    );

void main() {
  test('sends the chosen language to the preferences endpoint', () async {
    final api = _RecordingApi();

    await _sync(api: api, locale: const Locale('en')).sync();

    expect(api.paths, ['me/notification-preferences']);
    expect(api.bodies.single, {'locale': 'en'});
  });

  test('uses Arabic when the patient has not chosen a language', () async {
    final api = _RecordingApi();

    await _sync(api: api, locale: null).sync();

    expect(api.bodies.single, {'locale': 'ar'});
  });

  test('sends the device timezone with the language when it is known',
      () async {
    final api = _RecordingApi();

    await _sync(
      api: api,
      locale: const Locale('ar'),
      timezone: _FixedTimezone('Asia/Hebron'),
    ).sync();

    expect(api.bodies.single, {'locale': 'ar', 'timezone': 'Asia/Hebron'});
  });

  test('a blank timezone name is not sent', () async {
    final api = _RecordingApi();

    await _sync(api: api, timezone: _FixedTimezone('   ')).sync();

    expect(api.bodies.single, {'locale': 'ar'});
  });

  test('a timezone that cannot be read is left out, and the sync goes on',
      () async {
    final api = _RecordingApi();

    await expectLater(
      _sync(api: api, timezone: _FixedTimezone('x', fails: true)).sync(),
      completes,
    );

    expect(api.bodies.single, {'locale': 'ar'});
  });

  test('a name the server rejects is sent once more without it', () async {
    final api = _RecordingApi([
      const ApiException('bad zone', statusCode: 422, code: 'invalid_timezone'),
      null,
    ]);

    await _sync(
      api: api,
      locale: const Locale('en'),
      timezone: _FixedTimezone('Asia/Nowhere'),
    ).sync();

    expect(api.bodies, [
      {'locale': 'en', 'timezone': 'Asia/Nowhere'},
      {'locale': 'en'},
    ]);
  });

  test('a failed retry is logged and does not throw', () async {
    final api = _RecordingApi([
      const ApiException('bad zone', statusCode: 422, code: 'invalid_timezone'),
      NetworkException('offline', kind: NetworkFailureKind.offline),
    ]);

    await expectLater(
      _sync(api: api, timezone: _FixedTimezone('Asia/Nowhere')).sync(),
      completes,
    );

    expect(api.bodies, hasLength(2));
  });

  test('other refusals are not retried', () async {
    final api = _RecordingApi([
      const ApiException('nope', statusCode: 422, code: 'something_else'),
    ]);

    await _sync(api: api, timezone: _FixedTimezone('Asia/Hebron')).sync();

    expect(api.bodies, hasLength(1));
  });

  test('an invalid_timezone answer is not retried when no timezone was sent',
      () async {
    final api = _RecordingApi([
      const ApiException('bad zone', statusCode: 422, code: 'invalid_timezone'),
    ]);

    await _sync(api: api).sync();

    expect(api.bodies, hasLength(1));
  });

  test('never throws, even when the server cannot be reached', () async {
    final api = _RecordingApi([
      NetworkException('offline', kind: NetworkFailureKind.offline),
    ]);

    await expectLater(
      _sync(api: api, locale: const Locale('ar')).sync(),
      completes,
    );
    expect(api.bodies, hasLength(1));
  });

  group('syncIfZoneChanged (guide 10.5: whenever the timezone changes)', () {
    test('sends nothing when the timezone is the one last sent', () async {
      final api = _RecordingApi();
      final sync = _sync(
        api: api,
        locale: const Locale('ar'),
        timezone: _ChangingTimezone('Asia/Hebron'),
      );

      await sync.sync();
      await sync.syncIfZoneChanged();

      expect(api.bodies, hasLength(1));
    });

    test('sends the new timezone when it has changed', () async {
      final api = _RecordingApi();
      final zone = _ChangingTimezone('Asia/Hebron');
      final sync = _sync(api: api, locale: const Locale('ar'), timezone: zone);

      await sync.sync();
      zone.name = 'Europe/Paris';
      await sync.syncIfZoneChanged();

      expect(api.bodies, hasLength(2));
      expect(api.bodies.last, {'locale': 'ar', 'timezone': 'Europe/Paris'});
    });

    test('a timezone that cannot be read sends nothing', () async {
      final api = _RecordingApi();
      final zone = _ChangingTimezone('Asia/Hebron');
      final sync = _sync(api: api, timezone: zone);

      await sync.sync();
      zone.fails = true;
      await sync.syncIfZoneChanged();

      expect(api.bodies, hasLength(1));
    });

    test('a name the server rejects is not sent again on every resume',
        () async {
      final api = _RecordingApi([
        const ApiException('bad zone',
            statusCode: 422, code: 'invalid_timezone'),
        null,
      ]);
      final sync = _sync(api: api, timezone: _ChangingTimezone('Asia/Nowhere'));

      await sync.sync();
      await sync.syncIfZoneChanged();

      expect(api.bodies, hasLength(2));
    });

    test('after a failed sync the next resume sends the settings', () async {
      final api = _RecordingApi([
        NetworkException('offline', kind: NetworkFailureKind.offline),
      ]);
      final sync = _sync(api: api, timezone: _ChangingTimezone('Asia/Hebron'));

      await sync.sync();
      await sync.syncIfZoneChanged();

      expect(api.bodies, hasLength(2));
    });
  });
}
