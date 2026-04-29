import 'package:memory_storage/memory_storage.dart';
import 'package:test/test.dart';

void main() {
  group('InMemorySecureStorage', () {
    late InMemorySecureStorage storage;

    setUp(() => storage = InMemorySecureStorage());

    test('read returns null for absent key', () async {
      expect(await storage.read('missing'), isNull);
    });

    test('write then read returns stored value', () async {
      await storage.write('token', 'abc123');
      expect(await storage.read('token'), 'abc123');
    });

    test('write overwrites existing value', () async {
      await storage.write('token', 'old');
      await storage.write('token', 'new');
      expect(await storage.read('token'), 'new');
    });

    test('remove makes key absent', () async {
      await storage.write('token', 'abc');
      await storage.remove('token');
      expect(await storage.read('token'), isNull);
    });

    test('contains returns false for absent key', () async {
      expect(await storage.contains('missing'), isFalse);
    });

    test('contains returns true for present key', () async {
      await storage.write('token', 'abc');
      expect(await storage.contains('token'), isTrue);
    });
  });
}
