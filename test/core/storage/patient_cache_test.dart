import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/storage/patient_cache.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';

class _Cache implements PatientCache {
  _Cache(this.name, this.log, {this.fails = false});

  final String name;
  final List<String> log;
  final bool fails;

  @override
  Future<void> forgetPatientData() async {
    log.add(name);
    if (fails) throw StateError('disk unavailable');
  }
}

void main() {
  test('every cache runs in the order given, even after one fails', () async {
    final log = <String>[];

    await forgetPatientCaches([
      _Cache('queue', log),
      _Cache('meals', log, fails: true),
      _Cache('measurements', log),
    ]);

    expect(log, ['queue', 'meals', 'measurements']);
  });

  test('stored values listed for the patient are removed, others are kept',
      () async {
    final storage = MemoryStorageService();
    await storage.writeString(StorageKeys.locale, 'en');
    await storage.writeString(StorageKeys.healthProfile, '{}');
    await storage.writeString(StorageKeys.session, '{}');

    await StoredPatientData(
      storage,
      [StorageKeys.session, StorageKeys.healthProfile],
    ).forgetPatientData();

    expect(await storage.containsKey(StorageKeys.session), isFalse);
    expect(await storage.containsKey(StorageKeys.healthProfile), isFalse);
    expect(await storage.readString(StorageKeys.locale), 'en');
  });
}
