import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/errors/failure.dart';
import 'package:healthylife_ai/core/state/async_state.dart';

void main() {
  test('dataOrNull keeps the previous data while loading or after an error',
      () {
    expect(const AsyncSuccess<String>('plan').dataOrNull, 'plan');
    expect(const AsyncLoading<String>(previous: 'plan').dataOrNull, 'plan');
    expect(
      const AsyncError<String>(NetworkFailure(), previous: 'plan').dataOrNull,
      'plan',
    );
  });

  test('dataOrNull is null when there was nothing to keep', () {
    expect(const AsyncInitial<String>().dataOrNull, isNull);
    expect(const AsyncLoading<String>().dataOrNull, isNull);
    expect(const AsyncError<String>(NetworkFailure()).dataOrNull, isNull);
  });

  test('when reaches every phase with the right payload', () {
    String describe(AsyncState<String> state) => state.when(
          initial: () => 'initial',
          loading: (previous) => 'loading:${previous ?? '-'}',
          success: (data) => 'success:$data',
          error: (failure, previous) => 'error:${previous ?? '-'}',
        );

    expect(describe(const AsyncInitial()), 'initial');
    expect(describe(const AsyncLoading(previous: 'x')), 'loading:x');
    expect(describe(const AsyncSuccess('x')), 'success:x');
    expect(
        describe(const AsyncError(NetworkFailure(), previous: 'x')), 'error:x');
  });
}
