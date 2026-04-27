# api_network

API contract layer for the mobile platform network stack.

This package is the **single dependency** for feature and data layers that perform API calls or parse API responses. It aggregates transport contracts so consumers never depend on implementation packages such as `dio_network`.

---

## Purpose

This package exists to solve:

- Feature/data layers coupling directly to Dio or `dio_network`
- Leaking implementation details (`DioException`, Dio types) into upper layers
- Inconsistent API response parsing across features

---

## Scope

This package provides:

- `NetworkCallHandler` — the transport-layer contract
- `ObjectResponse<T>` — standard single-object API response wrapper
- `PaginatedResponse<T>` — paginated API response wrapper
- `PaginationResponse` — pagination metadata
- `ApiErrorResponse` — standardized error response structure

---

## Out of Scope

This package does NOT provide:

- HTTP client implementations (see `dio_network`)
- Dio or Retrofit integrations
- `DioBuilder` or `DioRestHandler` (implementation details in `dio_network`)
- Repository abstractions, domain entities, or business logic

---

## Architecture Position

```
Feature / Data Source
        ↓  depends on
   api_network          ← this package (contracts)
        ↑  implemented by
   dio_network          (Dio implementation — app/DI layer only)
```

---

## NetworkCallHandler Contract

`NetworkCallHandler` is the single abstraction point for all HTTP calls. Your data source depends only on this interface, never on Dio error types:

```dart
abstract class NetworkCallHandler {
  Future<T> handle<T>(Future<T> Function() apiCall);
}
```

The handler executes the call, catches transport-layer exceptions, and maps them to `Failure` subtypes before they reach the repository.

---

## Usage

### In a data source

```dart
import 'package:api_network/api_network.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({
    required this.client,
    required this.handler,
  });

  final Dio client;
  final NetworkCallHandler handler; // injected — DioRestHandler wired by DI

  Future<ObjectResponse<ProfileDto>> getProfile() {
    return handler.handle(() async {
      final response = await client.get<Map<String, dynamic>>('/me');
      return ObjectResponse.fromJson(
        response.data!,
        (json) => ProfileDto.fromJson(json as Map<String, dynamic>),
      );
    });
  }
}
```

### In the app / DI layer (only place that imports `dio_network`)

```dart
import 'package:dio_network/dio_network.dart';

final dio = DioBuilder('https://api.example.com')
    .setTimeouts(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    )
    .addHeader('Accept', 'application/json')
    .build();

final handler = DioRestHandler();

final dataSource = ProfileRemoteDataSource(client: dio, handler: handler);
```

### Catch only Failure in upper layers

```dart
try {
  final profile = await dataSource.getProfile();
} on Failure catch (failure) {
  // map failure to UI state or retry flow
}
```

---

## Dependency Rules

**Allowed** dependencies:

- `failures` (for `Failure` types)
- `dependencies` (for JSON annotation and serialization)

**Disallowed** dependencies:

- `dio_network` (implementation — would break the abstraction)
- `dio` / `retrofit` directly
- Feature packages, domain packages, or presentation packages

---

## Breaking Change Policy

Breaking changes require a major version bump and consumer migration notes.

Examples of breaking changes:

- Renaming or removing response fields
- Changing field types
- Changing the `NetworkCallHandler` contract signature
- Changing pagination structure

- Changing `RestApiHandler` signature
- Removing exported symbols

---

## Testing

Required coverage includes:

- JSON deserialization tests
- Backend contract tests
- Snake_case mapping validation
- Generic response parsing tests

Run tests:

```bash
dart test
```

---

## Ownership

Maintainer: Mobile Platform Team

Owner: Core Architecture Guild

Changes to response contracts or exported interfaces should be reviewed by package owners before merge.
