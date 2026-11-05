import 'package:flutter_test/flutter_test.dart';
import 'package:healthylife_ai/core/storage/legacy_storage.dart';
import 'package:healthylife_ai/core/storage/storage_service.dart';

/// Refuses every removal, as a failing platform store would.
class _RefusingStorage extends MemoryStorageService {
  @override
  Future<void> remove(String key) async => throw StateError('store is locked');
}

void main() {
  group('removeLegacyStorage', () {
    test('removes the pre-launch keys and keeps the rest', () async {
      final storage = MemoryStorageService();
      await storage.writeString(StorageKeys.session, '{}');
      await storage.writeString(StorageKeys.measurements, '[]');
      await storage.writeString(StorageKeys.locale, 'ar');

      await removeLegacyStorage(storage);

      expect(await storage.containsKey(StorageKeys.session), isFalse);
      expect(await storage.containsKey(StorageKeys.measurements), isFalse);
      expect(await storage.readString(StorageKeys.locale), 'ar');
    });

    test('a store with none of the keys is left as it is', () async {
      final storage = MemoryStorageService();

      await removeLegacyStorage(storage);

      expect(await storage.containsKey(StorageKeys.session), isFalse);
      expect(await storage.containsKey(StorageKeys.measurements), isFalse);
    });

    test('a removal that is refused does not stop start-up', () async {
      await expectLater(removeLegacyStorage(_RefusingStorage()), completes);
    });
  });
}
