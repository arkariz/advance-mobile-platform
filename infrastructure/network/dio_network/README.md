# dio_network

Network infrastructure package built on Dio. Provides the concrete `NetworkCallHandler` implementation and a Dio client builder.

This package provides:

- `DioBuilder` — fluent builder for consistent `Dio` client configuration
- `DioRestHandler` — implements `NetworkCallHandler` from `api_network`
- `DioFailureMapper` — maps `DioException` to domain `Failure` types (used internally)

> **Important**: This package should only be imported by the app layer (DI registration). Feature code and repositories must depend only on `api_network` (`NetworkCallHandler`), never on this package directly.

---

## Usage

### 1. Build a Dio client

```dart
final dio = DioBuilder('https://api.example.com')
    .setTimeouts(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    )
    .addHeader('Accept', 'application/json')
    .build();
```

### 2. Register in the root DI container

`DioRestHandler` and `Dio` are registered once at the root container level and forwarded to feature scopes via `bridge()`:

```dart
// In the root @module (injectable)
@module
abstract class RootModule {
  @lazySingleton
  NetworkCallHandler networkCallHandler() => DioRestHandler();
}
```

Feature scopes forward it via `bridge()`:

```dart
@override
void bridge(GetIt c) {
  c.registerSingleton<NetworkCallHandler>(parent<NetworkCallHandler>());
}
```

### 3. Catch only Failure in upper layers

`DioRestHandler` maps all `DioException` and `FormatException` to `Failure` subtypes automatically:

```dart
try {
  final products = await repository.getProducts();
} on Failure catch (failure) {
  // NetworkFailure, AuthenticationFailure, ValidationFailure — never DioException
}
```

---

## Failure Mapping

| Exception | Maps to |
|-----------|---------|
| No internet / connection timeout | `NetworkFailure` |
| HTTP 401 | `AuthenticationFailure` |
| HTTP 422 / validation body | `ValidationFailure` |
| `FormatException` (JSON parse error) | `NetworkFailure` |
| Other HTTP errors | `NetworkFailure` |

---

## Notes

- Keep all HTTP-specific concerns in this package.
- Feature and domain layers must depend only on `Failure` (from `failures`) and `NetworkCallHandler` (from `api_network`) — never on `DioException` or any Dio type.

