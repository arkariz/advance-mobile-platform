import 'package:failures/failures.dart';

/// A boundary adapter for executing REST calls and translating
/// infrastructure exceptions into domain [Failure] objects.
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
///     required this.rest,
///   });
///
///   final Dio client;
///   final RestApiHandler rest;
///
///   Future<Map<String, dynamic>> getProfile() {
///     return rest.handle(() async {
///       final response = await client.get<Map<String, dynamic>>('/me');
///       return response.data ?? <String, dynamic>{};
///     });
///   }
/// }
/// ```
///
// ignore: one_member_abstracts
abstract class RestApiHandler {
  /// Executes [apiCall] and returns its result.
  ///
  /// Implementations should catch transport-layer exceptions and throw
  /// domain [Failure] objects instead.
  Future<T> handle<T>(Future<T> Function() apiCall);
}
