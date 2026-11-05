import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/storage/secure_vault.dart';
import 'package:healthylife_ai/data/datasources/session_local_data_source.dart';

void main() {
  test('clearing the session also runs the patient-data cleanup', () async {
    var cleared = 0;
    final session = SessionLocalDataSource(
      MemorySecureVault(),
      onCleared: () async {
        cleared++;
      },
    );

    await session.clear();

    expect(cleared, 1);
  });

  test('a failing cleanup does not stop the session from being cleared',
      () async {
    final vault = MemorySecureVault();
    await vault.write('auth.session.v2', '{}');
    final session = SessionLocalDataSource(
      vault,
      onCleared: () async => throw StateError('storage unavailable'),
    );

    await session.clear();

    expect(await vault.read('auth.session.v2'), isNull);
  });
}
