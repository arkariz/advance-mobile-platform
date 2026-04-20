import 'package:failures/failures.dart';

/// Infrastructure metadata attached to a [Failure] for observability
/// and debugging.
///
/// Not all fields will be present for every failure source. Network
/// failures typically include [httpStatusCode] and [traceId], while
/// persistence failures may only carry [cause] and [stackTrace].
///
/// This sparse design allows each mapper to fill in only what its
/// source provides, without requiring adapters or null-object patterns.
final class FailureDetails {
  /// Creates a [FailureDetails] with the given fields.
  FailureDetails({
    this.traceId,
    this.httpStatusCode,
    this.backendCode,
    DateTime? timestamp,
    this.cause,
    this.stackTrace,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Distributed trace ID for correlating with backend observability.
  final String? traceId;

  /// HTTP status code, if the failure originated from a network request.
  final int? httpStatusCode;

  /// Raw error code returned by the backend service.
  ///
  /// Preserved verbatim for audit trails and backend correlation.
  final String? backendCode;

  /// When this failure was created.
  final DateTime timestamp;

  /// The original exception or error that caused this failure.
  ///
  /// Retained for error reporting tools (Sentry, Crashlytics).
  /// Must never be serialized or exposed to the UI layer.
  final Object? cause;

  /// Stack trace captured at the point of failure.
  final StackTrace? stackTrace;

  @override
  String toString() =>
    'FailureDetails(traceId: $traceId, httpStatusCode: $httpStatusCode, '
    'backendCode: $backendCode, timestamp: $timestamp)';
}
