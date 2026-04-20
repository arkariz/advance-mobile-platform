import 'package:failures/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure subclasses', () {

    test('NetworkFailure creates properly', () {
      const failure = NetworkFailure(
        code: FailureCode.timeout,
        message: 'timeout',
      );

      expect(
        failure,
        isA<Failure>(),
      );

      expect(
        failure.code,
        FailureCode.timeout,
      );
    });

    test('AuthenticationFailure defaults re-auth', () {
      const failure = AuthenticationFailure(
        code: FailureCode.tokenExpired,
        message: 'expired',
      );

      expect(
        failure.recovery,
        RecoveryOptions.reAuthenticate,
      );
    });

    test('ValidationFailure stores field errors', () {
      const failure = ValidationFailure(
        code: FailureCode.validationFailed,
        message: 'invalid',
        fieldErrors: {
          'email': ['required'],
        },
      );

      expect(
        failure.fieldErrors['email'],
        ['required'],
      );
    });

    test('ValidationFailure defaults empty field errors', () {
      const failure = ValidationFailure(
        code: FailureCode.validationFailed,
        message: 'invalid',
      );

      expect(
        failure.fieldErrors,
        isEmpty,
      );
    });

    test('Failure stores details', () {
      final details = FailureDetails(
        traceId: 'trace-1',
      );

      final failure = ServerFailure(
        code: FailureCode.serverError,
        message: 'server',
        details: details,
      );

      expect(
        failure.details,
        details,
      );
    });

    test('Failure stores userMessage', () {
      const failure = SystemFailure(
        code: FailureCode.unknown,
        message: 'internal',
        userMessage: 'Something went wrong',
      );

      expect(
        failure.userMessage,
        'Something went wrong',
      );
    });

    test('toString contains type', () {
      const failure = NetworkFailure(
        code: FailureCode.timeout,
        message: 'timeout',
      );

      expect(
        failure.toString(),
        contains('NetworkFailure'),
      );
    });

    test('ValidationFailure toString contains field errors', () {
      const failure = ValidationFailure(
        code: FailureCode.validationFailed,
        message: 'invalid',
        fieldErrors: {
          'name': ['required']
        },
      );

      expect(
        failure.toString(),
        contains('fieldErrors'),
      );
    });

  });
}
