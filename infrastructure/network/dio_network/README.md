# dio_network

Network infrastructure package built on Dio.

This package provides:

- `DioBuilder` for consistent `Dio` client configuration.
- `DioRestHandler` implementation of `RestApiHandler`.
- `DioFailureMapper` integration (used internally by `DioRestHandler`) to map
	`DioException` into domain `Failure` objects.

## Usage

### 1) Build a Dio client

```dart
final dio = DioBuilder('https://api.example.com')
		.setTimeouts(
			connectTimeout: const Duration(seconds: 15),
			receiveTimeout: const Duration(seconds: 15),
		)
		.addHeader('Accept', 'application/json')
		.build();
```

### 2) Use DioRestHandler in a data source

`DioRestHandler` executes requests and automatically maps `DioException`
to domain `Failure` via `DioFailureMapper`.

```dart
class ProductRemoteDataSource {
	ProductRemoteDataSource({
		required this.client,
		RestApiHandler? rest,
	}) : rest = rest ?? DioRestHandler();

	final Dio client;
	final RestApiHandler rest;

	Future<List<dynamic>> getProducts() {
		return rest.handle(() async {
			final response = await client.get<List<dynamic>>('/products');
			return response.data ?? <dynamic>[];
		});
	}
}
```

### 3) Catch only Failure in upper layers

```dart
try {
	final products = await remoteDataSource.getProducts();
	// render products
} on Failure catch (failure) {
	// map failure to UI state or retry flow
}
```

## Notes

- Keep HTTP-specific concerns in this package.
- Keep domain and presentation layers dependent on `Failure`, not `DioException`.
