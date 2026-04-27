# failures

Core failure model for domain-safe error handling.

This package provides a sealed `Failure` hierarchy, typed `FailureCode`s,
observability metadata (`FailureDetails`), and recovery hints (`RecoveryOptions`).

---

## Features

- Sealed `Failure` hierarchy for exhaustive, compile-time-safe handling
- Typed and extensible `FailureCode` values
- Optional metadata (`FailureDetails`) for logs and tracing
- Recovery strategy hints (`RecoveryOptions`) for UI/app logic

---

## Failure Hierarchy

```
Failure (sealed)
├── NetworkFailure      ← No internet, timeout, SSL error
├── AuthenticationFailure ← HTTP 401, token expired
└── ValidationFailure   ← HTTP 422, server-side validation rejection
```

Each `Failure` can carry:
- `FailureCode` — machine-readable code for programmatic handling
- `FailureDetails` — human-readable message for logging or display
- `RecoveryOptions` — user-actionable steps (e.g., "Retry", "Log in again")

---

## Usage

### Handle failures exhaustively

```dart
String messageFor(Failure failure) {
  return switch (failure) {
    NetworkFailure() => 'No internet connection',
    AuthenticationFailure() => 'Please log in again',
    ValidationFailure(:final fieldErrors)
        when fieldErrors.isNotEmpty => fieldErrors.values.first.first,
    _ => failure.userMessage ?? 'Something went wrong',
  };
}
```

### Catch `Failure` in a repository or BLoC

Network calls wrapped in `NetworkCallHandler.handle()` (from `api_network`) automatically map
transport exceptions into `Failure` subtypes before they reach the repository:

```dart
try {
  final account = await repository.getAccount();
} on Failure catch (failure) {
  // Handle by type — exhaustive via sealed class
  emit(state.withEffect(ShowSnackBarEffect(
    message: failure.details?.message ?? 'Something went wrong',
    severity: FeedbackSeverity.error,
  )));
}
```

---

## Architecture Position

```
BLoC / Use Case
      ↑ catches Failure
  Repository
      ↑ throws Failure
  NetworkCallHandler  ← maps DioException → Failure (in api_network/dio_network)
      ↑ wraps
  Retrofit datasource
```

This package defines only the `Failure` types. The `NetworkCallHandler` contract that
maps transport exceptions to `Failure` lives in `api_network`. The concrete Dio
implementation lives in `dio_network`.

