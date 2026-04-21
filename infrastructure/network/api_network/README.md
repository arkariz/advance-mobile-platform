# api_network

API contract layer for the mobile platform network stack.

This package is the **single dependency** for feature and data layers that perform API calls or parse API responses. It aggregates transport contracts so consumers never depend on implementation packages such as `dio_network`.

---

## Purpose

This package exists to solve:

- Feature/data layers coupling directly to Dio or `dio_network`
- Leaking implementation details (DioException, Dio types) into upper layers
- Inconsistent API response parsing across features

This package is the single source of truth for API-layer contracts.

---

## Scope

This package provides:

- Transport-contract models for consistent API parsing

Models and contracts included:

- `ObjectResponse<T>`
- `PaginatedResponse<T>`
- `PaginationResponse`
- `ApiErrorResponse`

---

## Out of Scope

This package does NOT provide:

- HTTP client implementations (see `dio_network`)
- Dio or Retrofit integrations
- `DioBuilder` or `DioRestHandler` (implementation details in `dio_network`)
- Repository abstractions
- Domain entities
- Business logic
- Presentation models

---

## Architecture Position

```text
Feature / Data Source
        ↓  depends on
   api_network          ← this package (contracts)
        ↑  implemented by
   dio_network          (Dio implementation — app/DI layer only)
```

---

## Usage

### In a data source

```dart
import 'package:api_network/api_network.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({
    required this.client,
    required this.rest,
  });

  final Dio client;            // injected — type comes from dio_network at app layer
  final RestApiHandler rest;   // injected — DioRestHandler wired by DI

  Future<ObjectResponse<ProfileDto>> getProfile() {
    return rest.handle(() async {
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

final rest = DioRestHandler();

final dataSource = ProfileRemoteDataSource(client: dio, rest: rest);
```

### Catch only Failure in upper layers

```dart
try {
  final profile = await dataSource.getProfile();
  // render profile
} on Failure catch (failure) {
  // map failure to UI state or retry flow
}
```

---

## Dependency Rules

Allowed dependencies:

- `failures` (for `RestApiHandler` and `Failure` contracts)
- `dependencies` (for JSON annotation and serialization)

Disallowed dependencies:

- `dio_network` (implementation — would break the abstraction)
- `dio` / `retrofit` directly
- Feature packages
- Domain packages
- Presentation packages

---

## Breaking Change Policy

Breaking changes require:

- Major version bump
- Consumer migration notes
- Backend contract validation

Examples of breaking changes:

- Renaming response fields
- Changing field types
- Changing pagination contract
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
