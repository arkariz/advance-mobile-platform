import 'package:failures/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FailureCode', () {
    test('creates from constructor', () {
      const code = FailureCode('CUSTOM_ERROR');

      expect(code.value, 'CUSTOM_ERROR');
    });

    test('creates from backend factory', () {
      const code = FailureCode.fromBackend('BE_422');

      expect(code.value, 'BE_422');
    });

    test('supports value equality', () {
      const a = FailureCode('TIMEOUT');
      const b = FailureCode('TIMEOUT');

      expect(a, equals(b));
    });

    test('has consistent hashCode', () {
      const a = FailureCode('TIMEOUT');
      const b = FailureCode('TIMEOUT');

      expect(a.hashCode, b.hashCode);
    });

    test('toString returns value', () {
      expect(
        FailureCode.timeout.toString(),
        'NETWORK_TIMEOUT',
      );
    });

    test('predefined constants are correct', () {
      expect(
        FailureCode.unauthenticated.value,
        'AUTH_UNAUTHENTICATED',
      );

      expect(
        FailureCode.parseError.value,
        'SYSTEM_PARSE_ERROR',
      );
    });
  });
}
