import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/core/state/async_state.dart';
import 'package:healthylife_ai/domain/entities/progress_entities.dart';
import 'package:healthylife_ai/domain/repositories/progress_repository.dart';
import 'package:healthylife_ai/presentation/bloc/progress/progress_cubit.dart';

/// Records each window asked for and answers with the next future in line.
class _ScriptedProgress implements ProgressRepository {
  final List<({DateTime from, DateTime to})> windows = [];
  final List<Future<Result<ProgressSnapshot>>> answers = [];

  @override
  Future<Result<ProgressSnapshot>> getProgress({
    required DateTime from,
    required DateTime to,
  }) {
    windows.add((from: from, to: to));
    return answers.removeAt(0);
  }
}

const ProgressSnapshot _snapshot = ProgressSnapshot(
  weightTrend: [],
  latestWeightKg: 82,
  weightChangeKg: -1,
  adherence: AdherenceSummary(percent: 72, changePp: null),
);

const ProgressSnapshot _other = ProgressSnapshot(
  weightTrend: [],
  latestWeightKg: 80,
  weightChangeKg: -2,
  adherence: AdherenceSummary(percent: 60, changePp: null),
);

void main() {
  final now = DateTime(2026, 10, 14, 10, 22);

  test('the first load asks for the last 30 days, today included', () async {
    final repo = _ScriptedProgress()
      ..answers.add(Future.value(const Success(_snapshot)));
    final cubit = ProgressCubit(repo, clock: () => now);
    addTearDown(cubit.close);

    await cubit.load();

    expect(repo.windows.single.from, DateTime(2026, 9, 15));
    expect(repo.windows.single.to, DateTime(2026, 10, 14));
    expect(cubit.state.dataOrNull?.latestWeightKg, 82);
  });

  test('the 90-day range asks for the window that starts 89 days back',
      () async {
    final repo = _ScriptedProgress()
      ..answers.add(Future.value(const Success(_snapshot)));
    final cubit = ProgressCubit(repo, clock: () => now);
    addTearDown(cubit.close);

    await cubit.load(days: 90);

    expect(cubit.days, 90);
    expect(repo.windows.single.from, DateTime(2026, 7, 17));
  });

  test('a failed refresh keeps the snapshot already on screen', () async {
    final repo = _ScriptedProgress()
      ..answers.addAll([
        Future.value(const Success(_snapshot)),
        Future.value(Failed<ProgressSnapshot>(const NetworkFailure())),
      ]);
    final cubit = ProgressCubit(repo, clock: () => now);
    addTearDown(cubit.close);
    await cubit.load();

    await cubit.load();

    expect(cubit.state, isA<AsyncError<ProgressSnapshot>>());
    expect(cubit.state.dataOrNull?.adherence.percent, 72);
  });

  test('a result for a window the patient has left is dropped', () async {
    final slow = Completer<Result<ProgressSnapshot>>();
    final repo = _ScriptedProgress()
      ..answers.addAll([
        slow.future,
        Future.value(const Success(_other)),
      ]);
    final cubit = ProgressCubit(repo, clock: () => now);
    addTearDown(cubit.close);

    final thirtyDays = cubit.load();
    await cubit.load(days: 90);
    slow.complete(const Success(_snapshot));
    await thirtyDays;

    expect(cubit.days, 90);
    expect(cubit.state.dataOrNull?.latestWeightKg, 80);
  });
}
