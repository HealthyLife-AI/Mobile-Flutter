import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/data/datasources/progress_remote_data_source.dart';
import 'package:healthylife_ai/data/repositories/progress_repository_impl.dart';

/// Records each GET with its query. A GET answers with [answer]; an
/// [AppException] answer is thrown.
class _ProgressApi implements ApiClient {
  final List<String> paths = [];
  final List<Map<String, dynamic>?> queries = [];
  Object? answer;

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    paths.add(path);
    queries.add(query);
    final next = answer;
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

Map<String, dynamic> _answer({int percent = 72}) => {
      'weight_trend': [
        {
          'recorded_at': '2026-10-06',
          'weight_kg': 83.2,
          'source': 'clinic-analyser'
        },
      ],
      'body_composition': {'latest': null, 'change': null},
      'adherence': {'adherence_percent': percent, 'change_pp': null},
      'daily_calories': <Object?>[],
    };

const NetworkException _offline =
    NetworkException('no connection', kind: NetworkFailureKind.offline);

void main() {
  late _ProgressApi api;
  late MemoryStorageService storage;
  late ProgressRepositoryImpl repository;

  final from = DateTime(2026, 9, 15);
  final to = DateTime(2026, 10, 14);

  setUp(() {
    api = _ProgressApi();
    storage = MemoryStorageService();
    repository = ProgressRepositoryImpl(
      storage,
      ProgressRemoteDataSource(api),
    );
  });

  test('the window is sent as clinic dates in YYYY-MM-DD form (8, 1.2)',
      () async {
    api.answer = _answer();

    await repository.getProgress(from: from, to: to);

    expect(api.paths, ['me/progress']);
    expect(api.queries.single, {'from': '2026-09-15', 'to': '2026-10-14'});
  });

  test('the answer is read into the snapshot', () async {
    api.answer = _answer(percent: 72);

    final result = await repository.getProgress(from: from, to: to);

    expect(result.valueOrNull?.adherence.percent, 72);
    expect(result.valueOrNull?.weightTrend.single.weightKg, 83.2);
  });

  test('offline, the copy of the same window is shown', () async {
    api.answer = _answer(percent: 72);
    await repository.getProgress(from: from, to: to);

    api.answer = _offline;
    final result = await repository.getProgress(from: from, to: to);

    expect(result.valueOrNull?.adherence.percent, 72);
  });

  test('offline, a copy of another window is not shown', () async {
    api.answer = _answer();
    await repository.getProgress(from: from, to: to);

    api.answer = _offline;
    final result = await repository.getProgress(
      from: DateTime(2026, 7, 17),
      to: to,
    );

    expect(result.failureOrNull, isA<NetworkFailure>());
  });

  test('offline with nothing kept is a network failure', () async {
    api.answer = _offline;

    final result = await repository.getProgress(from: from, to: to);

    expect(result.failureOrNull, isA<NetworkFailure>());
  });

  test('an answer that is not an object is an unexpected answer', () async {
    api.answer = <Object>[];

    final result = await repository.getProgress(from: from, to: to);

    expect(result.failureOrNull, isA<UnexpectedFailure>());
  });

  test('signing out forgets the copy', () async {
    api.answer = _answer();
    await repository.getProgress(from: from, to: to);

    await repository.forgetPatientData();
    api.answer = _offline;
    final result = await repository.getProgress(from: from, to: to);

    expect(result.failureOrNull, isA<NetworkFailure>());
  });
}
