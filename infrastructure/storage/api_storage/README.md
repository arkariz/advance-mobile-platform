# api_storage

Contract layer for storage. This package contains only ports (interfaces), serializers, and models — **no I/O, no dependencies on Hive or flutter_secure_storage**.

Feature and domain layers import only this package. Implementation details (`hive_storage`) are known only to the DI root.

---

## Public API

| Symbol | Type | Description |
|---|---|---|
| `ReadWriteStorage` | `abstract interface` | Base port: `read`, `write`, `remove`, `contains` |
| `KeyValueStorage` | `abstract interface` | Extends `ReadWriteStorage` + `clear()` |
| `SecureStorage` | `abstract interface` | Extends `ReadWriteStorage`, no `clear()` |
| `StorageKey` | `final class` | Structured key with `namespace` + `name` |
| `StoredValue<T>` | `final class` | Typed accessor — compose key + serializer + storage |
| `StorageSerializer<T>` | `abstract interface` | Port encoder/decoder: `encode(T)` / `decode(String)` |
| `JsonSerializer<T>` | `final class` | `StorageSerializer` implementation via `dart:convert` |
| `StorageFailureCode` | `abstract final class` | `FailureCode` constants for storage errors |

---

## Ports

### `ReadWriteStorage`

Base interface implemented by `KeyValueStorage` and `SecureStorage`. All methods throw `PersistenceFailure` on error.

```dart
abstract interface class ReadWriteStorage {
  Future<String?> read(String key);
  Future<void>    write(String key, String value);
  Future<void>    remove(String key);
  Future<bool>    contains(String key);
}
```

### `KeyValueStorage`

For non-sensitive data. Adds `clear()` on top of `ReadWriteStorage`.

```dart
abstract interface class KeyValueStorage implements ReadWriteStorage {
  Future<void> clear();
}
```

### `SecureStorage`

For sensitive data (tokens, sessions). `clear()` is **intentionally absent** — wiping all credentials at once is an irreversible operation.

```dart
abstract interface class SecureStorage implements ReadWriteStorage {}
```

---

## StorageKey

Structured key with namespace to prevent collision across features, especially when sharing a single box.

```dart
abstract final class AuthStorageKeys {
  static const session = StorageKey(namespace: 'auth', name: 'session');
  static const userId  = StorageKey(namespace: 'auth', name: 'user_id');
}

// Generated key strings: "auth_session", "auth_user_id"
print(AuthStorageKeys.session.value); // → auth_session
```

---

## StoredValue\<T\>

Typed accessor that unifies `StorageKey`, `StorageSerializer<T>`, and `ReadWriteStorage`. Repositories don't need to deal with raw JSON strings.

### `.json` constructor (recommended)

```dart
final _session = StoredValue.json(
  key:      AuthStorageKeys.session,
  fromJson: Session.fromJson,
  toJson:   (s) => s.toJson(),
  storage:  _secureStorage,
);
```

### Primary constructor with custom serializer

```dart
final _theme = StoredValue(
  key:        AppStorageKeys.theme,
  serializer: MyThemeSerializer(),
  storage:    _kvStorage,
);
```

### Methods

```dart
final session = await _session.read();   // Session? — null if not set
await _session.write(newSession);
await _session.remove();
final exists = await _session.exists();  // bool
```

Works with both `KeyValueStorage` and `SecureStorage` since both implement `ReadWriteStorage`.

---

## JsonSerializer\<T\>

Serializer based on `dart:convert`. Throws `PersistenceFailure` (not `Exception`) if encode/decode fails.

```dart
final serializer = JsonSerializer<Profile>(
  fromJson: Profile.fromJson,
  toJson:   (p) => p.toJson(),
);

final encoded = serializer.encode(profile);  // → JSON string
final decoded = serializer.decode(encoded);  // → Profile
```

---

## Error handling

All storage errors are sent as `PersistenceFailure` — a domain type from `core/failures`. Storage-specific codes are available in `StorageFailureCode`:

| Code | Constant | When it occurs |
|---|---|---|
| `PERSISTENCE_KEY_NOT_FOUND` | `StorageFailureCode.keyNotFound` | Key not found (if implementation enforces strict mode) |
| `PERSISTENCE_SERIALIZATION_FAILED` | `StorageFailureCode.serializationFailed` | `JsonSerializer` encode/decode fails |

---

## Dependencies

```
api_storage
└── failures (core/failures)
```

No Flutter SDK dependencies — can be used in pure Dart packages.

---

## Package structure

```
lib/
└── api_storage.dart          ← barrel export
    src/
    ├── failure_codes/
    │   └── storage_failure_code.dart
    ├── models/
    │   └── storage_key.dart
    ├── ports/
    │   ├── base/
    │   │   └── read_write_storage.dart
    │   ├── key_value_storage.dart
    │   └── secure_storage.dart
    ├── serializers/
    │   ├── json_serializer.dart
    │   └── storage_serializer.dart
    └── stored_value/
        └── stored_value.dart
```
