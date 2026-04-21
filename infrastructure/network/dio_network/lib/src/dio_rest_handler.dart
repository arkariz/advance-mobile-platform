import 'package:dependencies/dependencies.dart';
import 'package:dio_network/src/dio_failure_mapper.dart';
import 'package:failures/failures.dart';

/// `RestApiHandler` implementation for Dio-based clients.
///
/// Executes the provided request callback and maps any [DioException]
/// to domain [Failure] instances using [DioFailureMapper].
///
/// ## Usage
///
/// ```dart
/// final rest = DioRestHandler();
///
/// final profile = await rest.handle(() async {
///   final response = await dio.get<Map<String, dynamic>>('/me');
///   return response.data ?? <String, dynamic>{};
/// });
/// ```
// ignore_for_file: only_throw_errors
class DioRestHandler implements RestApiHandler {
  @override
  Future<T> handle<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on FormatException catch (e, stackTrace) {
      throw DioFailureMapper.mapParseError(e, stackTrace);
    } on DioException catch (exception) {
      // Re-throw as domain failure so upper layers do not depend on Dio.
      throw DioFailureMapper.map(exception);
    } 
  }
}
