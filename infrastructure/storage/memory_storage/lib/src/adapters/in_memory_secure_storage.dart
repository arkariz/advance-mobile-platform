import 'package:api_storage/api_storage.dart';

/// In-memory [SecureStorage] for use in tests.
///
/// Mirrors [InMemoryKeyValueStorage] but implements [SecureStorage],
/// providing type-safe substitution for encrypted storage without
/// any real encryption or I/O.
///
/// ```dart
/// final secureStorage = InMemorySecureStorage();
/// await secureStorage.write('token', 'abc');
/// expect(await secureStorage.read('token'), 'abc');
/// ```
final class InMemorySecureStorage implements SecureStorage {
  final Map<String, String> _store = {};

  /// An unmodifiable view of the current storage state.
  Map<String, String> get entries => Map.unmodifiable(_store);

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;

  @override
  Future<void> remove(String key) async => _store.remove(key);

  @override
  Future<bool> contains(String key) async => _store.containsKey(key);
}
