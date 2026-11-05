import 'failure.dart';

/// Lightweight success/failure container used by every repository and use
/// case. Avoids try/catch plumbing through the domain layer and makes error
/// paths explicit.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) =>
      switch (this) {
        Success<T>(:final value) => success(value),
        Failed<T>(failure: final f) => failure(f),
      };

  bool get isSuccess => this is Success<T>;

  /// The value, or null when this is a [Failed].
  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failed<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Failed<T>(:final failure) => failure,
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;
}
