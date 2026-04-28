import 'package:failures/failures.dart';
import 'package:test/test.dart';

void main() {
  group('FailureDetails', () {
    test('creates with provided values', () {
      final details = FailureDetails(
        traceId: 'trace-123',
        httpStatusCode: 500,
        backendCode: 'E500',
      );

      expect(details.traceId, 'trace-123');
      expect(details.httpStatusCode, 500);
      expect(details.backendCode, 'E500');
    });

    test('auto generates timestamp', () {
      final details = FailureDetails();

      expect(details.timestamp, isNotNull);
    });

    test('uses provided timestamp', () {
      final time = DateTime(2025);

      final details = FailureDetails(
        timestamp: time,
      );

      expect(details.timestamp, time);
    });

    test('stores cause and stacktrace', () {
      final stack = StackTrace.current;

      final details = FailureDetails(
        cause: Exception('boom'),
        stackTrace: stack,
      );

      expect(details.cause, isA<Exception>());
      expect(details.stackTrace, stack);
    });

    test('toString contains fields', () {
      final details = FailureDetails(
        traceId: 'abc',
      );

      expect(
        details.toString(),
        contains('traceId: abc'),
      );
    });
  });
}
