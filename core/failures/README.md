# failures

Core failure model for domain-safe error handling.

This package provides a sealed `Failure` hierarchy, typed `FailureCode`s,
observability metadata (`FailureDetails`), recovery hints (`RecoveryOptions`),
and a `RestApiHandler` contract to map infrastructure exceptions before they
cross into your domain layer.

## Features

- Sealed `Failure` hierarchy for exhaustive handling.
- Typed and extensible `FailureCode` values.
- Optional metadata (`FailureDetails`) for logs and tracing.
- Recovery strategy hints (`RecoveryOptions`) for UI/app logic.
- `RestApiHandler` abstraction to keep repositories transport-agnostic.

## Usage

### 1) Handle failures exhaustively

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

### 2) Use RestApiHandler in your data source

`RestApiHandler` is the domain boundary for remote execution. Your data source
depends only on this interface, not on Dio (or any other HTTP client) error
types.

```dart
import 'package:dio/dio.dart';

class AccountRemoteDataSource {
	AccountRemoteDataSource({
		required this.client,
		required this.rest,
	});

	final Dio client;
	final RestApiHandler rest;

	Future<Map<String, dynamic>> getAccount() {
		return rest.handle(() async {
			final response = await client.get<Map<String, dynamic>>('/account');
			return response.data ?? <String, dynamic>{};
		});
	}
}
```

Call sites can catch only `Failure`:

```dart
try {
	final account = await remoteDataSource.getAccount();
	// Use account
} on Failure catch (failure) {
	// Render UI / trigger recovery based on failure type and recovery options
}
```

## RestApiHandler Implementations

This package defines only the `RestApiHandler` contract. Concrete network
implementations live in infrastructure packages.

For Dio, see `DioRestHandler` in the `network` package.
