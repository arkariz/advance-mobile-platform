import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:failures/failures.dart';
import 'package:firestore_storage/src/firestore_failure_code.dart';
import 'package:firestore_storage/src/firestore_failure_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

FirebaseException _exception(String code, [String? message]) =>
    FirebaseException(plugin: 'firebase_firestore', code: code, message: message);

void main() {
  group('mapFirestoreFailure', () {
    test('maps unavailable to a retryable NetworkFailure', () {
      final failure = mapFirestoreFailure(_exception('unavailable'), StackTrace.current);

      expect(failure, isA<NetworkFailure>());
      expect(failure.code, FailureCode.noConnection);
      expect(failure.recovery, RecoveryOptions.retryable);
    });

    test('maps deadline-exceeded to a retryable NetworkFailure', () {
      final failure = mapFirestoreFailure(_exception('deadline-exceeded'), StackTrace.current);

      expect(failure, isA<NetworkFailure>());
      expect(failure.code, FailureCode.timeout);
      expect(failure.recovery, RecoveryOptions.retryable);
    });

    test('maps cancelled to a NetworkFailure', () {
      final failure = mapFirestoreFailure(_exception('cancelled'), StackTrace.current);

      expect(failure, isA<NetworkFailure>());
      expect(failure.code, FailureCode.requestCancelled);
    });

    test('maps permission-denied to an AuthorizationFailure', () {
      final failure = mapFirestoreFailure(_exception('permission-denied'), StackTrace.current);

      expect(failure, isA<AuthorizationFailure>());
      expect(failure.code, FailureCode.forbidden);
    });

    test('maps unauthenticated to an AuthenticationFailure', () {
      final failure = mapFirestoreFailure(_exception('unauthenticated'), StackTrace.current);

      expect(failure, isA<AuthenticationFailure>());
      expect(failure.code, FailureCode.unauthenticated);
    });

    final persistenceCases = <String, FailureCode>{
      'not-found': FirestoreFailureCode.notFound,
      'already-exists': FirestoreFailureCode.alreadyExists,
      'invalid-argument': FirestoreFailureCode.invalidArgument,
      'failed-precondition': FirestoreFailureCode.failedPrecondition,
      'aborted': FirestoreFailureCode.aborted,
      'out-of-range': FirestoreFailureCode.outOfRange,
      'data-loss': FirestoreFailureCode.dataLoss,
      'resource-exhausted': FirestoreFailureCode.resourceExhausted,
      'unimplemented': FirestoreFailureCode.unimplemented,
      'internal': FirestoreFailureCode.internalError,
    };

    persistenceCases.forEach((grpcCode, failureCode) {
      test('maps $grpcCode to PersistenceFailure($failureCode)', () {
        final failure = mapFirestoreFailure(_exception(grpcCode), StackTrace.current);

        expect(failure, isA<PersistenceFailure>());
        expect(failure.code, failureCode);
      });
    });

    final retryableCodes = {'failed-precondition', 'aborted', 'resource-exhausted', 'internal'};
    for (final grpcCode in retryableCodes) {
      test('$grpcCode is retryable', () {
        final failure = mapFirestoreFailure(_exception(grpcCode), StackTrace.current);
        expect(failure.recovery, RecoveryOptions.retryable);
      });
    }

    test('maps an unrecognized code to PersistenceFailure(unknown)', () {
      final failure = mapFirestoreFailure(_exception('some-unmapped-code'), StackTrace.current);

      expect(failure, isA<PersistenceFailure>());
      expect(failure.code, FirestoreFailureCode.unknown);
    });

    test('preserves the backend code and cause in FailureDetails', () {
      final exception = _exception('not-found', 'No document to update');
      final failure = mapFirestoreFailure(exception, StackTrace.current);

      expect(failure.details?.backendCode, 'not-found');
      expect(failure.details?.cause, exception);
      expect(failure.message, 'No document to update');
    });

    test('falls back to the error code as message when message is null', () {
      final failure = mapFirestoreFailure(_exception('not-found'), StackTrace.current);

      expect(failure.message, 'not-found');
    });
  });
}
