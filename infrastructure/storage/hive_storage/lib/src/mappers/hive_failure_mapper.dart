import 'package:failures/failures.dart';

/// Converts a raw storage exception into a [PersistenceFailure].
///
/// Centralises the mapping so every adapter uses a single, consistent
/// error shape with full observability metadata.
final class HiveFailureMapper {
  const HiveFailureMapper._();

  /// Returns a [PersistenceFailure] wrapping [error] with [code] and
  /// a [FailureDetails] carrying the original cause and [stackTrace].
  static PersistenceFailure map(
    Object error,
    StackTrace stackTrace, {
    required FailureCode code,
  }) => PersistenceFailure(
    code: code,
    message: 'Storage error: $error',
    details: FailureDetails(cause: error, stackTrace: stackTrace),
  );
}
