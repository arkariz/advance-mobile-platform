import 'package:memory_storage/memory_storage.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryKeyValueStorage', () {
    late InMemoryKeyValueStorage storage;

    setUp(() => storage = InMemoryKeyValueStorage());

    test('read returns null for absent key', () async {
      expect(await storage.read('missing'), isNull);
    });

    test('write then read returns stored value', () async {
      await storage.write('key', 'value');
      expect(await storage.read('key'), 'value');
    });

    test('write overwrites existing value', () async {
      await storage.write('key', 'first');
      await storage.write('key', 'second');
      expect(await storage.read('key'), 'second');
    });

    test('remove makes key absent', () async {
      await storage.write('key', 'value');
      await storage.remove('key');
      expect(await storage.read('key'), isNull);
    });

    test('remove is no-op for absent key', () async {
      await expectLater(storage.remove('nonexistent'), completes);
    });

    test('contains returns false for absent key', () async {
      expect(await storage.contains('missing'), isFalse);
    });

    test('contains returns true for present key', () async {
      await storage.write('key', 'value');
      expect(await storage.contains('key'), isTrue);
    });

    test('contains returns false after remove', () async {
      await storage.write('key', 'value');
      await storage.remove('key');
      expect(await storage.contains('key'), isFalse);
    });

    test('clear removes all keys', () async {
      await storage.write('a', '1');
      await storage.write('b', '2');
      await storage.clear();
      expect(storage.entries, isEmpty);
    });

    test('entries exposes unmodifiable view of store', () async {
      await storage.write('x', '42');
      final view = storage.entries;
      expect(view['x'], '42');
      expect(() => view['y'] = 'z', throwsUnsupportedError);
    });
  });
}
