# Response Package

Standardized API response contracts used across mobile platform services.

This package provides shared response models for parsing transport-layer responses consistently across applications and services.

---

## Purpose

This package exists to solve:

- Inconsistent API response parsing across features
- Repeated response model implementations
- Drift in backend response contracts
- Unstandardized pagination structures
- Unstandardized error payload handling

This package establishes a single source of truth for response contracts.

---

## Scope

This package provides:

- Object response contracts
- Paginated response contracts
- API error response contracts
- Pagination metadata contracts

Models included:

- ObjectResponse<T>
- PaginatedResponse<T>
- PaginationResponse
- ApiErrorResponse

---

## Out of Scope

This package does NOT provide:

- HTTP client implementations
- Dio or Retrofit integrations
- Failure mapping
- Repository abstractions
- Domain entities
- Business logic
- Presentation models

These responsibilities belong to higher layers.

---

## Architecture Position

This package belongs to the transport contract layer.

```text
Application
↓
Feature
↓
Domain
↓
Infrastructure
↓
HTTP Client
↓
Response Package   ← this package
```

---

## API Contracts

## Object Response

Expected backend contract:

```json
{
  "code": 200,
  "data": {}
}
```

Usage:

```dart
final response = ObjectResponse<User>.fromJson(
  json,
  (json) => User.fromJson(json as Map<String, dynamic>),
);
```

---

## Paginated Response

Expected backend contract:

```json
{
  "code": 200,
  "data": [],
  "pagination": {
    "total_items": 100,
    "total_pages": 10,
    "current_page": 1,
    "items_per_page": 10
  }
}
```

Usage:

```dart
final response = PaginatedResponse<User>.fromJson(
  json,
  (json) => User.fromJson(json as Map<String,dynamic>),
);
```

---

## Error Response

Expected backend contract:

```json
{
  "code": "INVALID_TOKEN",
  "message": "Token expired",
  "user_message": "Please login again",
  "trace_id": "abc-123"
}
```

Usage:

```dart
final error = ApiErrorResponse.fromJson(json);
```

---

## Usage Rules

Consumers must follow these rules:

- Use ObjectResponse<T> for single-resource endpoints.

- Use PaginatedResponse<T> for collection endpoints.

- Use ApiErrorResponse only for transport-layer error parsing.

- Map response models into domain models before leaving data layer.

- Never expose response models directly to presentation layer.

---

## Dependency Rules

Allowed dependencies:

- json_annotation

Disallowed dependencies:

- flutter
- dio
- retrofit
- feature packages
- domain packages
- presentation packages

This package must remain transport-layer only.

---

## Anti-Patterns

Do NOT:

- Use response models as domain entities

- Add business logic to response models

- Add HTTP concerns into this package

- Add feature-specific response contracts here

- Leak response models into UI or presentation

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

- Changing required/optional fields

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

Maintainer:

Mobile Platform Team

Owner:

Core Architecture Guild

Changes to response contracts should be reviewed by package owners before merge.