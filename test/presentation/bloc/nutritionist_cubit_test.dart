import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/core/state/async_state.dart';
import 'package:healthylife_ai/domain/entities/nutritionist_entities.dart';
import 'package:healthylife_ai/domain/repositories/nutritionist_repository.dart';
import 'package:healthylife_ai/presentation/bloc/nutritionist/nutritionist_cubit.dart';

/// Gives the next scripted result each time it is asked.
class _ScriptedRepository implements NutritionistRepository {
  final List<Result<NutritionistProfile>> results = [];

  @override
  Future<Result<NutritionistProfile>> getProfile() async => results.removeAt(0);
}

const NutritionistProfile _profile = NutritionistProfile(name: 'د. أمل');

void main() {
  test('a successful load ends in success with the profile', () async {
    final repository = _ScriptedRepository()..results.add(Success(_profile));
    final cubit = NutritionistCubit(repository);
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, isA<AsyncSuccess<NutritionistProfile>>());
    expect(cubit.state.dataOrNull?.name, 'د. أمل');
  });

  test('a failed refresh keeps the profile already on screen', () async {
    final repository = _ScriptedRepository()
      ..results.add(Success(_profile))
      ..results.add(Failed(const NetworkFailure()));
    final cubit = NutritionistCubit(repository);
    addTearDown(cubit.close);

    await cubit.load();
    await cubit.load();

    expect(cubit.state, isA<AsyncError<NutritionistProfile>>());
    expect(cubit.state.dataOrNull?.name, 'د. أمل');
  });

  test('a failure with nothing before it shows the error and no data',
      () async {
    final repository = _ScriptedRepository()
      ..results.add(Failed(const NetworkFailure()));
    final cubit = NutritionistCubit(repository);
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, isA<AsyncError<NutritionistProfile>>());
    expect(cubit.state.dataOrNull, isNull);
  });
}
