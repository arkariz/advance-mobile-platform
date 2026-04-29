import 'package:api_storage/api_storage.dart';

/// In-memory [KeyValueStorage] for use in tests.
///
/// All state is held in a [Map]; no I/O occurs and no exceptions are thrown.
/// Use [entries] in tests to assert stored values directly:
///
/// ```dart
/// final storage = InMemoryKeyValueStorage();
/// await storage.write('key', 'value');
/// expect(storage.entries['key'], 'value');
/// ```
final class InMemoryKeyValueStorage implements KeyValueStorage {
  final Map<String, String> _store = {};

  /// An unmodifiable view of the current storage state.
  ///
  /// Useful for assertions in unit tests without calling [read].
  Map<String, String> get entries => Map.unmodifiable(_store);

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;

  @override
  Future<void> remove(String key) async => _store.remove(key);

  @override
  Future<bool> contains(String key) async => _store.containsKey(key);

  @override
  Future<void> clear() async => _store.clear();
}
