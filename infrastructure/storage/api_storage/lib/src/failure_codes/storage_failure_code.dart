import 'package:failures/failures.dart';

/// Storage-specific [FailureCode] constants.
///
/// Extend this pattern to define feature-specific storage codes without
/// modifying [FailureCode] in `core/failures`.
abstract final class StorageFailureCode {
  /// The requested key was not found in storage.
  static const keyNotFound = FailureCode('PERSISTENCE_KEY_NOT_FOUND');

  /// A [StorageSerializer] failed to encode or decode a value.
  static const serializationFailed = FailureCode('PERSISTENCE_SERIALIZATION_FAILED');
}
