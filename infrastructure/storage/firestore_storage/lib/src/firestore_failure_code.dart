import 'package:failures/failures.dart';

/// `FailureCode` values for Firestore-specific error conditions that have
/// no existing generic home in `core/failures`.
///
/// Conditions that already map cleanly onto an existing [FailureCode] reuse
/// it instead of duplicating a code here — e.g. a Firestore `unavailable`
/// error becomes [FailureCode.noConnection], not a new code. See
/// `firestore_failure_mapper.dart` for the full mapping.
abstract final class FirestoreFailureCode {
  /// The requested document does not exist.
  static const notFound = FailureCode('FIRESTORE_NOT_FOUND');

  /// A create attempted to overwrite a document that already exists.
  static const alreadyExists = FailureCode('FIRESTORE_ALREADY_EXISTS');

  /// The request contained an invalid field, value, or path.
  static const invalidArgument = FailureCode('FIRESTORE_INVALID_ARGUMENT');

  /// The operation was rejected because the system is not in the required
  /// state (e.g. a transaction precondition failed).
  static const failedPrecondition = FailureCode('FIRESTORE_FAILED_PRECONDITION');

  /// The operation was aborted, typically due to a transaction conflict.
  /// Safe to retry.
  static const aborted = FailureCode('FIRESTORE_ABORTED');

  /// An operation parameter was outside the valid range.
  static const outOfRange = FailureCode('FIRESTORE_OUT_OF_RANGE');

  /// Unrecoverable data loss or corruption.
  static const dataLoss = FailureCode('FIRESTORE_DATA_LOSS');

  /// A resource quota (e.g. rate limit, storage quota) was exhausted. Safe
  /// to retry after a delay.
  static const resourceExhausted = FailureCode('FIRESTORE_RESOURCE_EXHAUSTED');

  /// The operation is not implemented or not supported by the backend.
  static const unimplemented = FailureCode('FIRESTORE_UNIMPLEMENTED');

  /// An internal Firestore server error. Safe to retry.
  static const internalError = FailureCode('FIRESTORE_INTERNAL');

  /// An error Firestore reported without a code this mapper recognizes.
  static const unknown = FailureCode('FIRESTORE_UNKNOWN');
}
