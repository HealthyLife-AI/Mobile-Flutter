import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/result.dart';
import '../../../core/state/async_state.dart';
import '../../../domain/entities/review_entities.dart';
import '../../../domain/repositories/review_repository.dart';

/// Loads the nutritionist's notes and records the patient's acknowledgements
/// and task ticks. After a write succeeds, the list is read again, so the
/// screen shows what the server holds. A refresh that fails keeps the list
/// already on screen.
class ReviewsCubit extends Cubit<AsyncState<List<NutritionistReview>>> {
  ReviewsCubit(this._repository) : super(const AsyncInitial());

  final ReviewRepository _repository;

  Future<void> load() async {
    if (isClosed) return;
    final previous = state.dataOrNull;
    emit(AsyncLoading<List<NutritionistReview>>(previous: previous));
    final result = await _repository.getReviews();
    if (isClosed) return;
    result.when(
      success: (reviews) => emit(AsyncSuccess(reviews)),
      failure: (failure) => emit(AsyncError(failure, previous: previous)),
    );
  }

  Future<Result<void>> acknowledge(int reviewId) async {
    final result = await _repository.acknowledge(reviewId);
    if (result.isSuccess) await load();
    return result;
  }

  Future<Result<void>> setTaskDone(int taskId, {required bool done}) async {
    final result = await _repository.setTaskDone(taskId, done: done);
    if (result.isSuccess) await load();
    return result;
  }
}
