import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/errors/result.dart';
import 'package:healthylife_ai/core/state/async_state.dart';
import 'package:healthylife_ai/domain/entities/review_entities.dart';
import 'package:healthylife_ai/domain/repositories/review_repository.dart';
import 'package:healthylife_ai/presentation/bloc/reviews/reviews_cubit.dart';

/// Answers the list with the scripted results in order, and records writes.
class _ScriptedReviews implements ReviewRepository {
  final List<Result<List<NutritionistReview>>> lists = [];
  Result<void> writeResult = const Success<void>(null);
  final List<String> writes = [];
  int loads = 0;

  @override
  Future<Result<List<NutritionistReview>>> getReviews() async {
    loads++;
    return lists.removeAt(0);
  }

  @override
  Future<Result<void>> acknowledge(int reviewId) async {
    writes.add('acknowledge $reviewId');
    return writeResult;
  }

  @override
  Future<Result<void>> setTaskDone(int taskId, {required bool done}) async {
    writes.add('task $taskId done=$done');
    return writeResult;
  }
}

const NutritionistReview _review = NutritionistReview(
  id: 12,
  rating: ReviewRating.onTrack,
  note: 'Well done',
  keyPoints: [],
  tasks: [],
);

void main() {
  test('loading shows the notes', () async {
    final repo = _ScriptedReviews()..lists.add(const Success([_review]));
    final cubit = ReviewsCubit(repo);
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, isA<AsyncSuccess<List<NutritionistReview>>>());
    expect(cubit.state.dataOrNull?.single.id, 12);
  });

  test('a failed load is an error, with no notes to show', () async {
    final repo = _ScriptedReviews()
      ..lists.add(Failed<List<NutritionistReview>>(const NetworkFailure()));
    final cubit = ReviewsCubit(repo);
    addTearDown(cubit.close);

    await cubit.load();

    expect(cubit.state, isA<AsyncError<List<NutritionistReview>>>());
    expect(cubit.state.dataOrNull, isNull);
  });

  test('acknowledging records it, then reads the notes again', () async {
    final repo = _ScriptedReviews()
      ..lists.addAll([
        const Success([_review]),
        const Success([_review])
      ]);
    final cubit = ReviewsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();

    final result = await cubit.acknowledge(12);

    expect(result.isSuccess, isTrue);
    expect(repo.writes, ['acknowledge 12']);
    expect(repo.loads, 2);
  });

  test('a refused acknowledgement is returned and the notes are not read again',
      () async {
    final repo = _ScriptedReviews()
      ..lists.add(const Success([_review]))
      ..writeResult = const Failed<void>(NetworkFailure());
    final cubit = ReviewsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();

    final result = await cubit.acknowledge(12);

    expect(result.failureOrNull, isA<NetworkFailure>());
    expect(repo.loads, 1);
  });

  test('ticking a task sends the new state, then reads the notes again',
      () async {
    final repo = _ScriptedReviews()
      ..lists.addAll([
        const Success([_review]),
        const Success([_review])
      ]);
    final cubit = ReviewsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();

    await cubit.setTaskDone(40, done: true);

    expect(repo.writes, ['task 40 done=true']);
    expect(repo.loads, 2);
  });

  test('a refresh that fails keeps the notes already on screen', () async {
    final repo = _ScriptedReviews()
      ..lists.addAll([
        const Success([_review]),
        Failed<List<NutritionistReview>>(const NetworkFailure()),
      ]);
    final cubit = ReviewsCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();

    await cubit.load();

    expect(cubit.state, isA<AsyncError<List<NutritionistReview>>>());
    expect(cubit.state.dataOrNull?.single.id, 12);
  });
}
