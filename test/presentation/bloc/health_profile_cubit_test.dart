import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/core/state/async_state.dart';
import 'package:healthylife_ai/domain/entities/patient_health_profile_entities.dart';
import 'package:healthylife_ai/domain/repositories/health_profile_repository.dart';
import 'package:healthylife_ai/presentation/bloc/health_profile/health_profile_cubit.dart';

/// Gives the next scripted result each time it is asked, and records writes.
class _ScriptedRepository implements HealthProfileRepository {
  final List<Result<PatientHealthProfile>> results = [];
  Result<void> writeResult = const Success<void>(null);
  int loads = 0;
  final List<ChangeRequestDraft> proposed = [];
  final List<int> withdrawn = [];

  @override
  Future<Result<PatientHealthProfile>> getProfile() async {
    loads++;
    return results.removeAt(0);
  }

  @override
  Future<Result<void>> propose(ChangeRequestDraft draft) async {
    proposed.add(draft);
    return writeResult;
  }

  @override
  Future<Result<void>> withdraw(int proposalId) async {
    withdrawn.add(proposalId);
    return writeResult;
  }
}

const PatientHealthProfile _profile = PatientHealthProfile(
  goal: HealthGoal(goalType: 'weight_loss'),
);

void main() {
  test('a successful load ends in success with the profile', () async {
    final repository = _ScriptedRepository()..results.add(Success(_profile));
    final cubit = HealthProfileCubit(repository);
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, isA<AsyncSuccess<PatientHealthProfile>>());
    expect(cubit.state.dataOrNull?.goal?.goalType, 'weight_loss');
  });

  test('a failed refresh keeps the profile already on screen', () async {
    final repository = _ScriptedRepository()
      ..results.add(Success(_profile))
      ..results.add(Failed(const NetworkFailure()));
    final cubit = HealthProfileCubit(repository);
    addTearDown(cubit.close);

    await cubit.load();
    await cubit.load();

    expect(cubit.state, isA<AsyncError<PatientHealthProfile>>());
    expect(cubit.state.dataOrNull?.goal?.goalType, 'weight_loss');
  });

  test('a failure with nothing before it shows the error and no data',
      () async {
    final repository = _ScriptedRepository()
      ..results.add(Failed(const NetworkFailure()));
    final cubit = HealthProfileCubit(repository);
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, isA<AsyncError<PatientHealthProfile>>());
    expect(cubit.state.dataOrNull, isNull);
  });

  test('a request that is sent reads the profile again', () async {
    final repository = _ScriptedRepository()
      ..results.add(Success(_profile))
      ..results.add(Success(_profile));
    final cubit = HealthProfileCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();

    final result = await cubit.submit(const ChangeRequestDraft(
      kind: 'medication',
      action: 'add',
      data: {'name': 'Vitamin D'},
    ));

    expect(result.isSuccess, isTrue);
    expect(repository.proposed.single.kind, 'medication');
    expect(repository.loads, 2);
  });

  test('a refused request is returned and the profile is not read again',
      () async {
    final repository = _ScriptedRepository()
      ..results.add(Success(_profile))
      ..writeResult = const Failed<void>(ApiFailure(code: 'proposal_exists'));
    final cubit = HealthProfileCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();

    final result = await cubit.submit(const ChangeRequestDraft(
      kind: 'allergy',
      action: 'add',
      data: {'group': 'egg'},
    ));

    expect(result.failureOrNull, isA<ApiFailure>());
    expect(repository.loads, 1);
    expect(cubit.state, isA<AsyncSuccess<PatientHealthProfile>>());
  });

  test('a withdrawn request is removed and the profile is read again',
      () async {
    final repository = _ScriptedRepository()
      ..results.add(Success(_profile))
      ..results.add(Success(_profile));
    final cubit = HealthProfileCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();

    final result = await cubit.withdraw(14);

    expect(result.isSuccess, isTrue);
    expect(repository.withdrawn, [14]);
    expect(repository.loads, 2);
  });
}
