import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/data/datasources/review_remote_data_source.dart';
import 'package:healthylife_ai/data/repositories/review_repository_impl.dart';

/// Records each call. A GET answers with [answer]; a write answers with
/// [writeError] when one is set. An [AppException] answer is thrown.
class _RecordingApi implements ApiClient {
  final List<String> calls = [];
  Object? answer;
  AppException? writeError;

  @override
  Future<dynamic> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    calls.add('GET $path');
    final next = answer;
    if (next is AppException) throw next;
    return next;
  }

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) async {
    calls.add('POST $path');
    final error = writeError;
    if (error != null) throw error;
    return null;
  }

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) async {
    calls.add('DELETE $path');
    final error = writeError;
    if (error != null) throw error;
    return null;
  }
}

Map<String, dynamic> _review(int id) => {
      'id': id,
      'rating': 'on_track',
      'note': 'Well done',
      'key_points': <String>[],
      'tasks': [
        {'id': 40, 'title': 'Walk', 'done_at': null},
      ],
      'acknowledged_at': null,
      'edited_at': null,
      'created_at': '2026-10-06T12:00:00+00:00',
    };

const NetworkException _offline =
    NetworkException('no connection', kind: NetworkFailureKind.offline);

void main() {
  late _RecordingApi api;
  late MemoryStorageService storage;
  late ReviewRepositoryImpl repository;

  setUp(() {
    api = _RecordingApi();
    storage = MemoryStorageService();
    repository = ReviewRepositoryImpl(storage, ReviewRemoteDataSource(api));
  });

  test('reads the list and keeps it on the device', () async {
    api.answer = [_review(12), _review(13)];

    final result = await repository.getReviews();

    expect(api.calls, ['GET me/reviews']);
    expect(result.valueOrNull?.map((review) => review.id), [12, 13]);
    expect(await storage.containsKey(StorageKeys.reviews), isTrue);
  });

  test('offline, the kept list is shown', () async {
    api.answer = [_review(12)];
    await repository.getReviews();

    api.answer = _offline;
    final result = await repository.getReviews();

    expect(result.valueOrNull?.single.id, 12);
  });

  test('offline with nothing kept is a network failure', () async {
    api.answer = _offline;

    final result = await repository.getReviews();

    expect(result.failureOrNull, isA<NetworkFailure>());
  });

  test('an answer that is not a list is an unexpected answer', () async {
    api.answer = {'data': <Object>[]};

    final result = await repository.getReviews();

    expect(result.failureOrNull, isA<UnexpectedFailure>());
  });

  test('acknowledging posts to the note and succeeds', () async {
    final result = await repository.acknowledge(12);

    expect(api.calls, ['POST me/reviews/12/acknowledge']);
    expect(result.isSuccess, isTrue);
  });

  test('ticking a task posts, and unticking it deletes', () async {
    await repository.setTaskDone(40, done: true);
    await repository.setTaskDone(40, done: false);

    expect(api.calls, ['POST me/tasks/40/done', 'DELETE me/tasks/40/done']);
  });

  test('a refused acknowledgement keeps the code and the status', () async {
    api.writeError =
        const ApiException('not found', statusCode: 404, code: 'not_found');

    final result = await repository.acknowledge(99);

    final failure = result.failureOrNull;
    expect(failure, isA<ApiFailure>());
    final apiFailure = failure as ApiFailure;
    expect(apiFailure.statusCode, 404);
    expect(apiFailure.code, 'not_found');
  });

  test('signing out forgets the kept list', () async {
    api.answer = [_review(12)];
    await repository.getReviews();

    await repository.forgetPatientData();
    api.answer = _offline;
    final result = await repository.getReviews();

    expect(result.failureOrNull, isA<NetworkFailure>());
  });
}
