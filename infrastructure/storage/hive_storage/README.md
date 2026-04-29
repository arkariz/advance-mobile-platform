# hive_storage

Implementation of `api_storage` ports using [Hive CE](https://pub.dev/packages/hive_ce) — a community-maintained fork of Hive v2.

This package is imported only by the **DI root** (e.g., `RootModule`). Feature and domain layers do not know about this package.

---

## Adapters

### `HiveKeyValueStorage`

`KeyValueStorage` implementation backed by a Hive CE `Box<String>`. The box is opened outside the adapter (in the DI root), so there's one adapter per box.

```dart
// In RootModule:
await HiveStorageInitializer.init();
final box = await Hive.openBox<String>('app_kv');
final storage = HiveKeyValueStorage(box: box);
```

All Hive exceptions are translated to `PersistenceFailure` by `HiveFailureMapper`.

### `HiveSecureStorage`

`SecureStorage` implementation backed by an AES-256 encrypted `Box<String>`.

**How encryption works:**
1. On first launch, a 256-bit AES key is generated via `Hive.generateSecureKey()`
2. The key is stored in the platform's native keychain: **iOS Keychain** / **Android Keystore** via `flutter_secure_storage`
3. The key is loaded from the keychain each time the box is opened — never stored as plaintext on disk

Use the async factory `initialize()`:

```dart
final secureStorage = await HiveSecureStorage.initialize();

// Custom box name (optional, default: 'secure_kv'):
final secureStorage = await HiveSecureStorage.initialize(boxName: 'auth_secure');
```

`initialize()` calls `HiveStorageInitializer.init()` internally — no manual setup needed.

`clear()` is **not available** — as per the `SecureStorage` contract.

---

## HiveStorageInitializer

Thin wrapper around `Hive.initFlutter()`. Idempotent — safe to call multiple times.

```dart
await HiveStorageInitializer.init();
```

No need to call explicitly if using `HiveSecureStorage.initialize()`. Must be called explicitly before `Hive.openBox()` for `HiveKeyValueStorage`.

---

## DI Registration

All boxes are registered as `@preResolve` singletons in `RootModule`, so they're available before `runApp`.

### Multiple boxes

Use `@Named` to distinguish multiple boxes of the same type:

```dart
@module
abstract class RootModule {
  @singleton
  @preResolve
  @Named('app_kv')
  Future<KeyValueStorage> appKvStorage() async {
    await HiveStorageInitializer.init();
    final box = await Hive.openBox<String>('app_kv');
    return HiveKeyValueStorage(box: box);
  }

  @singleton
  @preResolve
  @Named('cache_kv')
  Future<KeyValueStorage> cacheKvStorage() async {
    await HiveStorageInitializer.init();
    final box = await Hive.openBox<String>('cache_kv');
    return HiveKeyValueStorage(box: box);
  }

  @singleton
  @preResolve
  Future<SecureStorage> secureStorage() => HiveSecureStorage.initialize();
}
```

Inject with qualifier at the call site:

```dart
class AuthStorage {
  AuthStorage({@Named('cache_kv') required KeyValueStorage cacheStorage});
}
```

---

## Error mapping

`HiveFailureMapper` translates all Hive exceptions to `PersistenceFailure` with the appropriate code:

| Operation | `FailureCode` |
|---|---|
| `read` | `FailureCode.readFailed` |
| `write` | `FailureCode.writeFailed` |
| `remove` / `clear` | `FailureCode.deleteFailed` |

---

## Dependencies

```
hive_storage
├── api_storage
├── failures (core/failures)
├── hive_ce: ^2.19.3
├── hive_ce_flutter: ^2.3.4
└── flutter_secure_storage: ^9.2.2
```

`flutter_secure_storage` is used only inside `HiveSecureStorage` for AES key custody. Never exposed outside this package.

---

## Platform setup

### Android

`android/app/build.gradle.kts` — minSdk must be at least 18 for `flutter_secure_storage`:

```kotlin
android {
    defaultConfig {
        minSdk = 18
    }
}
```

### iOS

No additional setup required. `flutter_secure_storage` uses Keychain by default.

---

## Package structure

```
lib/
└── hive_storage.dart          ← barrel export
    src/
    ├── adapters/
    │   ├── hive_key_value_storage.dart
    │   └── hive_secure_storage.dart
    ├── initializer/
    │   └── hive_storage_initializer.dart
    └── mappers/
        └── hive_failure_mapper.dart
```
