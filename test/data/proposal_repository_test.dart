import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/app_exception.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/network/api_client.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';
import 'package:healthylife_ai/data/datasources/health_profile_remote_data_source.dart';
import 'package:healthylife_ai/data/models/health_profile_dto.dart';
import 'package:healthylife_ai/data/repositories/health_profile_repository_impl.dart';
import 'package:healthylife_ai/domain/entities/patient_health_profile_entities.dart';

/// Records each write and answers with a scripted value, or throws the
/// scripted [AppException].
class _RecordingApi implements ApiClient {
  final List<String> calls = [];
  final List<Object?> bodies = [];
  Object? answer;

  Future<dynamic> _answer(String call, Object? body) async {
    calls.add(call);
    bodies.add(body);
    final next = answer;
    if (next is AppException) throw next;
    return next;
  }

  @override
  Future<dynamic> get(String path,
          {Map<String, dynamic>? query, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> post(String path, {Object? body, bool auth = true}) =>
      _answer('POST $path', body);

  @override
  Future<dynamic> put(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> patch(String path, {Object? body, bool auth = true}) =>
      throw UnimplementedError(path);

  @override
  Future<dynamic> delete(String path, {Object? body, bool auth = true}) =>
      _answer('DELETE $path', body);
}

void main() {
  late _RecordingApi api;
  late HealthProfileRepositoryImpl repository;

  setUp(() {
    api = _RecordingApi();
    repository = HealthProfileRepositoryImpl(
      MemoryStorageService(),
      HealthProfileRemoteDataSource(api),
    );
  });

  test('a goal is sent as an edit, with no target id', () async {
    final result = await repository.propose(const ChangeRequestDraft(
      kind: 'goal',
      action: 'edit',
      data: {'goal_type': 'weight_loss', 'target_weight_kg': 70},
    ));

    expect(result.isSuccess, isTrue);
    expect(api.calls.single, 'POST me/proposals');
    final body = api.bodies.single as Map<String, dynamic>;
    expect(body['kind'], 'goal');
    expect(body['action'], 'edit');
    expect(body.containsKey('target_id'), isFalse);
    expect((body['data'] as Map)['goal_type'], 'weight_loss');
  });

  test('an edit names the item it changes, and a removal sends no data',
      () async {
    await repository.propose(const ChangeRequestDraft(
      kind: 'medication',
      action: 'edit',
      targetId: 5,
      data: {'name': 'Metformin'},
    ));
    final edit = api.bodies.single as Map<String, dynamic>;
    expect(edit['target_id'], 5);
    expect(edit['data'], {'name': 'Metformin'});

    api.calls.clear();
    api.bodies.clear();
    await repository.propose(const ChangeRequestDraft(
      kind: 'allergy',
      action: 'remove',
      targetId: 2,
    ));
    final removal = api.bodies.single as Map<String, dynamic>;
    expect(removal['target_id'], 2);
    expect(removal.containsKey('data'), isFalse);
  });

  test('a refused request keeps the server code', () async {
    api.answer = const ApiException(
      'refused',
      statusCode: 409,
      code: 'proposal_exists',
    );

    final result = await repository.propose(const ChangeRequestDraft(
      kind: 'medication',
      action: 'add',
      data: {'name': 'Vitamin D'},
    ));

    expect(result.failureOrNull, isA<ApiFailure>());
    expect((result.failureOrNull as ApiFailure).code, 'proposal_exists');
  });

  test('offline, a request is sent once and is not queued or retried',
      () async {
    api.answer = const NetworkException('no connection');

    final result = await repository.propose(const ChangeRequestDraft(
      kind: 'goal',
      action: 'edit',
      data: {'goal_type': 'weight_loss'},
    ));

    expect(result.failureOrNull, isA<NetworkFailure>());
    expect(api.calls, hasLength(1));
  });

  test('withdrawing deletes the request by its id', () async {
    final result = await repository.withdraw(14);

    expect(result.isSuccess, isTrue);
    expect(api.calls.single, 'DELETE me/proposals/14');
  });

  test('the item a request is about is read from its payload', () {
    final profile = HealthProfileDto.fromJson({
      'proposals': [
        {
          'id': 14,
          'kind': 'medication',
          'action': 'add',
          'status': 'pending',
          'payload': {'name': 'Vitamin D'},
        },
      ],
    });

    expect(profile?.proposals.single.payload['name'], 'Vitamin D');
    expect(profile?.proposals.single.status, 'pending');
  });
}
