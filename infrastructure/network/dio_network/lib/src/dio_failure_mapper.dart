import 'package:dependencies/dependencies.dart';
import 'package:failures/failures.dart';
import 'package:response/response.dart';

/// Maps [DioException] instances to domain [Failure] objects.
///
/// This is the primary integration point between the network infrastructure
/// layer (Dio) and the domain failure model. All Dio errors should pass
/// through this mapper before reaching domain or presentation layers.
///
/// ## Mapping Table
///
/// | Dio Type | Failure Family |
/// |---|---|
/// | connectionTimeout, sendTimeout, receiveTimeout | [NetworkFailure] |
/// | connectionError | [NetworkFailure] |
/// | badCertificate | [SecurityFailure] |
/// | cancel | [NetworkFailure] |
/// | badResponse 401 | [AuthenticationFailure] |
/// | badResponse 403 | [AuthorizationFailure] |
/// | badResponse 422 | [ValidationFailure] |
/// | badResponse 4xx | [BusinessRuleFailure] |
/// | badResponse 5xx | [ServerFailure] |
/// | TypeError or FormatException (parse) | [SystemFailure] with [FailureCode.parseError] |
/// | unknown (DioException) | [SystemFailure] |
///
/// ## Usage
///
/// ```dart
/// try {
///   final response = await dio.get('/accounts');
///   return Right(response.data);
/// } on DioException catch (e, stackTrace) {
///   return Left(DioFailureMapper.map(e, stackTrace));
/// }
/// ```
abstract final class DioFailureMapper {
  /// Maps a [DioException] to the appropriate [Failure] subtype.
  ///
  /// Parses the response body as [ApiErrorResponse] when available
  /// to extract structured error information (code, message, traceId).
  ///
  /// Pass the [stackTrace] from the catch clause to preserve the full
  /// trace for error reporting.
  static Failure map(DioException exception, [StackTrace? stackTrace]) {
    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => NetworkFailure(
        code: FailureCode.timeout,
        message: exception.message ?? 'Request timed out',
        recovery: RecoveryOptions.retryable,
        details: FailureDetails(
          httpStatusCode: exception.response?.statusCode,
          cause: exception,
          stackTrace: stackTrace,
        ),
      ),
      DioExceptionType.connectionError => NetworkFailure(
        code: FailureCode.noConnection,
        message: exception.message ?? 'Connection failed',
        recovery: RecoveryOptions.retryable,
        details: FailureDetails(
          cause: exception,
          stackTrace: stackTrace,
        ),
      ),
      DioExceptionType.badCertificate => SecurityFailure(
        code: FailureCode.certificateInvalid,
        message: exception.message ?? 'Certificate validation failed',
        details: FailureDetails(
          cause: exception,
          stackTrace: stackTrace,
        ),
      ),
      DioExceptionType.cancel => NetworkFailure(
        code: FailureCode.requestCancelled,
        message: 'Request was cancelled',
        details: FailureDetails(
          cause: exception,
          stackTrace: stackTrace,
        ),
      ),
      DioExceptionType.badResponse => _mapBadResponse(
        exception,
        stackTrace,
      ),
      DioExceptionType.unknown => SystemFailure(
        code: FailureCode.unknown,
        message: exception.message ?? 'An unexpected error occurred',
        recovery: RecoveryOptions.retryable,
        details: FailureDetails(
          cause: exception,
          stackTrace: stackTrace,
        ),
      ),
    };
  }

  static Failure _mapBadResponse(
    DioException exception,
    StackTrace? stackTrace,
  ) {
    final statusCode = exception.response?.statusCode;
    ApiErrorResponse? apiError;

    try {
      apiError = _parseApiError(exception.response);
    } on FormatException catch (e, stackTrace) {
      return mapParseError(e, stackTrace);
    }

    final details = FailureDetails(
      httpStatusCode: statusCode,
      backendCode: apiError?.code,
      traceId: apiError?.traceId,
      cause: exception,
      stackTrace: stackTrace,
    );

    return switch (statusCode) {
      401 => AuthenticationFailure(
        code: FailureCode.unauthenticated,
        message: apiError?.message ?? 'Authentication required',
        userMessage: apiError?.userMessage,
        details: details,
      ),
      403 => AuthorizationFailure(
        code: FailureCode.forbidden,
        message: apiError?.message ?? 'Access denied',
        userMessage: apiError?.userMessage,
        details: details,
      ),
      422 => ValidationFailure(
        code: FailureCode.validationFailed,
        message: apiError?.message ?? 'Validation failed',
        userMessage: apiError?.userMessage,
        details: details,
      ),
      final code? when code >= 400 && code < 500 => BusinessRuleFailure(
        code: apiError != null
            ? FailureCode.fromBackend(apiError.code)
            : FailureCode.businessRuleViolation,
        message: apiError?.message ?? 'Request failed',
        userMessage: apiError?.userMessage,
        details: details,
      ),
      final code? when code >= 500 => ServerFailure(
        code: _mapServerCode(code),
        message: apiError?.message ?? 'Server error',
        userMessage: apiError?.userMessage,
        recovery: RecoveryOptions.retryable,
        details: details,
      ),
      _ => SystemFailure(
        code: FailureCode.unknown,
        message: 'Unexpected HTTP status code: $statusCode',
        details: details,
      ),
    };
  }

  /// Maps a [TypeError] or [FormatException] that occurred during response
  /// deserialization to a [SystemFailure] with [FailureCode.parseError].
  static SystemFailure mapParseError(Object error, StackTrace stackTrace) {
    final message = switch (error) {
      FormatException(:final message) => 'Response parse error: $message',
      _ => 'Response type mismatch: $error',
    };
    return SystemFailure(
      code: FailureCode.parseError,
      message: message,
      details: FailureDetails(cause: error, stackTrace: stackTrace),
    );
  }

  static FailureCode _mapServerCode(int statusCode) {
    return switch (statusCode) {
      502 => FailureCode.badGateway,
      503 => FailureCode.serviceUnavailable,
      504 => FailureCode.gatewayTimeout,
      _ => FailureCode.serverError,
    };
  }

  static ApiErrorResponse? _parseApiError(Response<dynamic>? response) {
    final data = response?.data;
    if (data is! Map<String, dynamic>) return null;

    // Prefer a dedicated `error` envelope; fall back to the root body.
    final errorNode = data['error'];
    final source = errorNode is Map<String, dynamic> ? errorNode : data;
    return ApiErrorResponse.fromJson(source);
  }
}
