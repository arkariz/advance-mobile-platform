import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:failures/failures.dart';

import 'package:firestore_storage/src/firestore_failure_code.dart';

/// Maps a [FirebaseException] thrown by `cloud_firestore` to a [Failure].
///
/// Conditions that already have a generic home in `core/failures` reuse
/// that [FailureCode] (e.g. `unavailable` → [NetworkFailure] with
/// [FailureCode.noConnection]) instead of duplicating it under
/// [FirestoreFailureCode]. Everything else maps to a [PersistenceFailure]
/// with a Firestore-specific code, mirroring how `api_storage` reports
/// local-persistence errors.
Failure mapFirestoreFailure(FirebaseException error, StackTrace stackTrace) {
  final details = FailureDetails(backendCode: error.code, cause: error, stackTrace: stackTrace);
  final message = error.message ?? error.code;

  switch (error.code) {
    case 'unavailable':
      return NetworkFailure(
        code: FailureCode.noConnection,
        message: message,
        recovery: RecoveryOptions.retryable,
        details: details,
      );
    case 'deadline-exceeded':
      return NetworkFailure(
        code: FailureCode.timeout,
        message: message,
        recovery: RecoveryOptions.retryable,
        details: details,
      );
    case 'cancelled':
      return NetworkFailure(code: FailureCode.requestCancelled, message: message, details: details);

    case 'permission-denied':
      return AuthorizationFailure(code: FailureCode.forbidden, message: message, details: details);
    case 'unauthenticated':
      return AuthenticationFailure(code: FailureCode.unauthenticated, message: message, details: details);

    case 'not-found':
      return PersistenceFailure(code: FirestoreFailureCode.notFound, message: message, details: details);
    case 'already-exists':
      return PersistenceFailure(code: FirestoreFailureCode.alreadyExists, message: message, details: details);
    case 'invalid-argument':
      return PersistenceFailure(code: FirestoreFailureCode.invalidArgument, message: message, details: details);
    case 'failed-precondition':
      return PersistenceFailure(
        code: FirestoreFailureCode.failedPrecondition,
        message: message,
        recovery: RecoveryOptions.retryable,
        details: details,
      );
    case 'aborted':
      return PersistenceFailure(
        code: FirestoreFailureCode.aborted,
        message: message,
        recovery: RecoveryOptions.retryable,
        details: details,
      );
    case 'out-of-range':
      return PersistenceFailure(code: FirestoreFailureCode.outOfRange, message: message, details: details);
    case 'data-loss':
      return PersistenceFailure(code: FirestoreFailureCode.dataLoss, message: message, details: details);
    case 'resource-exhausted':
      return PersistenceFailure(
        code: FirestoreFailureCode.resourceExhausted,
        message: message,
        recovery: RecoveryOptions.retryable,
        details: details,
      );
    case 'unimplemented':
      return PersistenceFailure(code: FirestoreFailureCode.unimplemented, message: message, details: details);
    case 'internal':
      return PersistenceFailure(
        code: FirestoreFailureCode.internalError,
        message: message,
        recovery: RecoveryOptions.retryable,
        details: details,
      );

    default:
      return PersistenceFailure(code: FirestoreFailureCode.unknown, message: message, details: details);
  }
}
