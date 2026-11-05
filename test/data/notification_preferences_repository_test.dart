import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/data/repositories/notification_preferences_repository_impl.dart';
import 'package:healthylife_ai/domain/entities/notification_preferences.dart';

/// Answers GET with [answer] (thrown when it is an exception) and records
/// each PUT body, answering it in the response's nested shape.
class _Api implements ApiClient {
  Object? answer;
  final List<Object?> puts = [];

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    final next = answer;
    if (next is AppException) throw next;
    return next;
  }

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) async {
    puts.add(body);
    final flat = body! as Map<String, dynamic>;
    return {
      'locale': 'ar',
      'categories': {
        'meals': flat['meals'],
        'measurements': flat['measurements'],
        'nutritionist': flat['nutritionist'],
        'plan': flat['plan'],
        'system': true,
      },
      'quiet_hours': {
        'enabled': flat['quiet_hours_enabled'],
        'start': flat['quiet_start'],
        'end': flat['quiet_end'],
      },
    };
  }

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

void main() {
  late _Api api;
  late MemoryStorageService storage;
  late NotificationPreferencesRepositoryImpl repository;

  setUp(() {
    api = _Api();
    storage = MemoryStorageService();
    repository = NotificationPreferencesRepositoryImpl(storage, api);
  });

  test('reads the nested answer (API guide 10.5)', () async {
    api.answer = {
      'locale': 'ar',
      'categories': {
        'meals': false,
        'measurements': true,
        'nutritionist': true,
        'plan': false,
        'system': true,
      },
      'quiet_hours': {'enabled': true, 'start': '23:30', 'end': '06:15'},
      'timezone': 'Asia/Gaza',
    };

    final prefs = (await repository.get()).valueOrNull!;

    expect(prefs.meals, isFalse);
    expect(prefs.plan, isFalse);
    expect(prefs.quietStartMinute, 23 * 60 + 30);
    expect(prefs.quietEndMinute, 6 * 60 + 15);
  });

  test('saves a flat request and keeps the answer', () async {
    final saved = (await repository.update(const NotificationPreferences(
            measurements: false, quietStartMinute: 21 * 60)))
        .valueOrNull!;

    expect(api.puts.single, {
      'meals': true,
      'measurements': false,
      'nutritionist': true,
      'plan': true,
      'quiet_hours_enabled': true,
      'quiet_start': '21:00',
      'quiet_end': '07:00',
    });
    expect(saved.measurements, isFalse);
    expect((await repository.known()).measurements, isFalse);
  });

  test('offline, the last answer is read', () async {
    await repository.update(const NotificationPreferences(meals: false));
    api.answer = const NetworkException('offline');

    final prefs = (await repository.get()).valueOrNull!;

    expect(prefs.meals, isFalse);
  });

  test('offline with nothing kept is a failure; known() is the defaults',
      () async {
    api.answer = const NetworkException('offline');

    final result = await repository.get();

    expect(result.failureOrNull, isA<NetworkFailure>());
    expect(await repository.known(), const NotificationPreferences());
  });

  test('signing out forgets the settings', () async {
    await repository.update(const NotificationPreferences(meals: false));

    await repository.forgetPatientData();

    expect(await repository.known(), const NotificationPreferences());
  });
}
