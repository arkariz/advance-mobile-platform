/// A boundary adapter for executing Network calls and translating
/// infrastructure exceptions into domain Failure objects.
///
/// Keep repositories/data sources unaware of transport-specific exceptions
/// (for example DioException) by delegating execution to this handler.
///
/// ## Usage
///
/// ```dart
/// class ProfileRemoteDataSource {
///   ProfileRemoteDataSource({
///     required this.client,
///     required this.handler,
///   });
///
///   final Dio client;
///   final NetworkCallHandler handler;
///
///   Future<Map<String, dynamic>> getProfile() {
///     return handler.handle(() async {
///       final response = await client.get<Map<String, dynamic>>('/me');
///       return response.data ?? <String, dynamic>{};
///     });
///   }
/// }
/// ```
///
// ignore: one_member_abstracts
abstract class NetworkCallHandler {
  /// Executes [apiCall] and returns its result.
  ///
  /// Implementations should catch transport-layer exceptions and throw
  /// domain Failure objects instead.
  Future<T> handle<T>(Future<T> Function() apiCall);
}
