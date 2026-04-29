# memory_storage

In-memory implementation of `api_storage` ports for use in **unit tests**. All state is held in a `Map<String, String>` — no I/O, no Hive, no Flutter SDK dependency.

---

## Adapters

### `InMemoryKeyValueStorage`

`KeyValueStorage` implementation. Never throws exceptions.

```dart
final storage = InMemoryKeyValueStorage();

await storage.write('key', 'value');
final value = await storage.read('key');   // → 'value'
await storage.remove('key');
await storage.clear();
```

### `InMemorySecureStorage`

`SecureStorage` implementation. Identical to `InMemoryKeyValueStorage` but without `clear()` — as per the `SecureStorage` contract.

```dart
final secure = InMemorySecureStorage();

await secure.write('token', 'abc123');
final token = await secure.read('token'); // → 'abc123'
```

---

## Escape hatch: `entries`

Both adapters expose an `entries` getter — a read-only snapshot of the internal map. Use in tests to verify storage state without calling `read()`:

```dart
// Verify that data was actually written to storage
expect(storage.entries, {'app_current_user': '{"id":"1",...}'});
expect(storage.entries, isNotEmpty);
expect(storage.entries, isEmpty); // after clear/signOut
```

> `entries` is **not available on production adapters** (`HiveKeyValueStorage`, `HiveSecureStorage`) — this is a test-only API.

---

## Usage in unit tests

### Basic setup

```dart
setUp(() {
  final secureStorage = InMemorySecureStorage();
  final cacheStorage  = InMemoryKeyValueStorage();

  final appStorage  = AppStorage(secureStorage: secureStorage);
  final authStorage = AuthStorage(cacheStorage: cacheStorage);

  repository = AuthRepositoryImpl(
    dataSource:         _StubDatasource(),
    networkCallHandler: _PassthroughHandler(),
    appStorage:         appStorage,
    authStorage:        authStorage,
  );
});
```

No need for `async` setUp — both adapters can be instantiated synchronously, unlike `HiveSecureStorage.initialize()`.

### Verify via domain method

```dart
test('writes user on sign-in', () async {
  await repository.signIn(email: 'user@example.com', password: 'pass');

  // Domain-level assertion (recommended):
  expect(await repository.getSignedInUser(), tUser);

  // Raw-level assertion (to verify data was actually persisted):
  expect(secureStorage.entries, isNotEmpty);
});
```

### Verify storage isolation

```dart
test('sign-out clears both storages', () async {
  await repository.signIn(email: 'user@example.com', password: 'pass');
  await repository.signOut();

  expect(secureStorage.entries, isEmpty);
  expect(cacheStorage.entries, isEmpty);
});
```

### Verify namespace key

Since `StorageKey.value` produces `'<namespace>_<name>'`, it can be verified directly:

```dart
test('uses correct key', () async {
  await repository.signIn(email: 'user@example.com', password: 'pass');

  expect(secureStorage.entries.containsKey('app_current_user'), isTrue);
  expect(cacheStorage.entries.containsKey('auth_cached_user'), isTrue);
});
```

---

## Dependencies

```
memory_storage
└── api_storage
```

No Flutter SDK, no Hive, no platform channels. Can be used in pure Dart tests (`dart test`).

---

## Package structure

```
lib/
└── memory_storage.dart        ← barrel export
    src/
    └── adapters/
        ├── in_memory_key_value_storage.dart
        └── in_memory_secure_storage.dart
test/
├── in_memory_key_value_storage_test.dart
└── in_memory_secure_storage_test.dart
```
