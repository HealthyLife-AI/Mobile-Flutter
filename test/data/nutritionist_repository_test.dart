import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/data/datasources/nutritionist_remote_data_source.dart';
import 'package:healthylife_ai/data/repositories/nutritionist_repository_impl.dart';

/// Answers `GET me/nutritionist` with the next scripted answer: a value is
/// returned, an [AppException] is thrown.
class _ScriptedApi implements ApiClient {
  final List<Object> answers = [];

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    if (answers.isEmpty) throw StateError('No answer scripted for $path');
    final next = answers.removeAt(0);
    if (next is AppException) throw next;
    return next;
  }

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);
}

const Map<String, dynamic> _answer = {
  'name': 'د. أمل',
  'clinic_name': 'عيادة الشفاء',
  'whatsapp_number': '+970599123456',
};

NutritionistRepositoryImpl _repository(
  _ScriptedApi api,
  StorageService storage,
) =>
    NutritionistRepositoryImpl(storage, NutritionistRemoteDataSource(api));

void main() {
  late _ScriptedApi api;
  late StorageService storage;

  setUp(() {
    api = _ScriptedApi();
    storage = MemoryStorageService();
  });

  test('the server answer is returned', () async {
    api.answers.add(_answer);

    final result = await _repository(api, storage).getProfile();

    expect(result.valueOrNull?.name, 'د. أمل');
    expect(result.valueOrNull?.clinicName, 'عيادة الشفاء');
  });

  test('offline, the last answer is shown', () async {
    api.answers.add(_answer);
    await _repository(api, storage).getProfile();

    // A new repository on the same storage, as after a restart.
    api.answers.add(const NetworkException('no connection'));
    final result = await _repository(api, storage).getProfile();

    expect(result.valueOrNull?.name, 'د. أمل');
  });

  test('offline with nothing kept fails as a network problem', () async {
    api.answers.add(const NetworkException('no connection'));

    final result = await _repository(api, storage).getProfile();

    expect(result.failureOrNull, isA<NetworkFailure>());
  });

  test('an answer without a name fails and keeps nothing', () async {
    api.answers.add({'clinic_name': 'عيادة'});
    final first = await _repository(api, storage).getProfile();
    expect(first.isSuccess, isFalse);

    api.answers.add(const NetworkException('no connection'));
    final second = await _repository(api, storage).getProfile();
    expect(second.failureOrNull, isA<NetworkFailure>());
  });

  test('clearing the patient data removes the kept answer', () async {
    api.answers.add(_answer);
    await _repository(api, storage).getProfile();

    await _repository(api, storage).forgetPatientData();

    api.answers.add(const NetworkException('no connection'));
    final result = await _repository(api, storage).getProfile();
    expect(result.failureOrNull, isA<NetworkFailure>());
  });
}
