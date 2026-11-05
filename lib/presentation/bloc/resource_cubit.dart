import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/result.dart';
import '../../core/state/async_state.dart';

/// One server resource on screen, with the same rules as `MealPlanCubit`:
///
/// * a refresh keeps the data already shown while it loads and when it fails;
/// * [reset] forgets the data (the patient left), and a load that finishes
///   after a reset is dropped, since it belongs to the patient who left;
/// * [changes] (a push, a save elsewhere) reads it again, but only for a
///   patient who is in the app.
///
/// Each feature subclasses it once, so a screen can `context.read` the
/// feature's own cubit type.
class ResourceCubit<T> extends Cubit<AsyncState<T>> {
  ResourceCubit(this._fetch, {Stream<void>? changes})
      : super(AsyncInitial<T>()) {
    _changes = changes?.listen((_) {
      if (state is! AsyncInitial<T>) unawaited(load());
    });
  }

  final Future<Result<T>> Function() _fetch;
  StreamSubscription<void>? _changes;
  int _generation = 0;

  Future<void> load() async {
    if (isClosed) return;
    final generation = _generation;
    final previous = state.dataOrNull;
    emit(AsyncLoading<T>(previous: previous));
    final result = await _fetch();
    if (isClosed || generation != _generation) return;
    result.when(
      success: (data) => emit(AsyncSuccess<T>(data)),
      failure: (failure) => emit(AsyncError<T>(failure, previous: previous)),
    );
  }

  /// Shows [data] without a read, e.g. the answer a write returned.
  void put(T data) {
    if (!isClosed) emit(AsyncSuccess<T>(data));
  }

  void reset() {
    _generation++;
    if (!isClosed) emit(AsyncInitial<T>());
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }
}
