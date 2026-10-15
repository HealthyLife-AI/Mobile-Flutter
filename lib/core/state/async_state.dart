import 'package:flutter/foundation.dart';

import '../errors/failure.dart';

/// The four phases every feature moves through (architecture brief, Module 2):
///
/// * [AsyncInitial]: nothing requested yet.
/// * [AsyncLoading]: a request is in flight. Show a skeleton, not a spinner.
/// * [AsyncSuccess]: data is ready.
/// * [AsyncError]: the request failed. Show the message and a retry action.
///
/// Loading and error keep [previous] data when there was some, so a refresh
/// never blanks a screen that already showed content.
@immutable
sealed class AsyncState<T> {
  const AsyncState();

  /// Data to keep showing while a refresh is loading or after it failed.
  T? get dataOrNull => switch (this) {
        AsyncSuccess<T>(:final data) => data,
        AsyncLoading<T>(:final previous) => previous,
        AsyncError<T>(:final previous) => previous,
        AsyncInitial<T>() => null,
      };

  /// Exhaustive dispatch over the four phases.
  R when<R>({
    required R Function() initial,
    required R Function(T? previous) loading,
    required R Function(T data) success,
    required R Function(Failure failure, T? previous) error,
  }) =>
      switch (this) {
        AsyncInitial<T>() => initial(),
        AsyncLoading<T>(:final previous) => loading(previous),
        AsyncSuccess<T>(:final data) => success(data),
        AsyncError<T>(:final failure, :final previous) =>
          error(failure, previous),
      };
}

final class AsyncInitial<T> extends AsyncState<T> {
  const AsyncInitial();
}

final class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading({this.previous});

  final T? previous;
}

final class AsyncSuccess<T> extends AsyncState<T> {
  const AsyncSuccess(this.data);

  final T data;
}

final class AsyncError<T> extends AsyncState<T> {
  const AsyncError(this.failure, {this.previous});

  final Failure failure;
  final T? previous;
}
