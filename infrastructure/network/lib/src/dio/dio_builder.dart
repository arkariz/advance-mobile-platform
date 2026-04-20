import 'package:dependencies/dependencies.dart';

/// Builder for configuring and creating Dio instances with a fluent API.
/// Provides methods to set base URL, timeouts, headers, and interceptors before
/// building the final Dio client.
///
/// ## Usage
///```dart
/// final dio = DioBuilder('https://api.example.com')
///     .setTimeouts(connectTimeout: Duration(seconds: 10), receiveTimeout: Duration(seconds: 30))
///     .addHeader('Authorization', 'Bearer token')
///     .addInterceptor(LogInterceptor())
///     .build();
///```
// ignore_for_file: avoid_returning_this
class DioBuilder {
  
  /// Initializes the builder with a base URL for the Dio client.
  DioBuilder(String baseUrl) : _client = Dio(BaseOptions(baseUrl: baseUrl));
  final Dio _client;

  /// Sets connection and receive timeouts for the Dio client.
  DioBuilder setTimeouts({Duration? connectTimeout, Duration? receiveTimeout}) {
    _client.options.connectTimeout = connectTimeout;
    _client.options.receiveTimeout = receiveTimeout;
    return this;
  }

  /// Adds a header to the Dio client.
  DioBuilder addHeader(String key, String? value) {
    if (value != null) {
      _client.options.headers[key] = value;
    }
    return this;
  }

  /// Adds multiple headers to the Dio client.
  DioBuilder addHeaders(Map<String, dynamic> headers) {
    _client.options.headers.addAll(headers);
    return this;
  }

  /// Adds an interceptor to the Dio client.
  DioBuilder addInterceptor(Interceptor interceptor) {
    _client.interceptors.add(interceptor);
    return this;
  }

  /// Builds and returns the configured Dio client.
  Dio build() {
    return _client;
  }
}
