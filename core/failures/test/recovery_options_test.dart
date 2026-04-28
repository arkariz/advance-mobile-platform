import 'package:failures/failures.dart';
import 'package:test/test.dart';

void main() {
  group('RecoveryOptions', () {
    test('none defaults correctly', () {
      expect(
        RecoveryOptions.none,
        RecoveryOptions.none,
      );
    });

    test('retryable sets retry flag', () {
      expect(
        RecoveryOptions.retryable.isRetryable,
        true,
      );

      expect(
        RecoveryOptions.retryable.requiresReAuthentication,
        false,
      );
    });

    test('reAuthenticate sets auth flag', () {
      expect(
        RecoveryOptions.reAuthenticate.requiresReAuthentication,
        true,
      );

      expect(
        RecoveryOptions.reAuthenticate.isRetryable,
        false,
      );
    });

    test('supports equality', () {
      expect(
        RecoveryOptions.retryable,
        RecoveryOptions.retryable,
      );
    });

    test('hashCode matches equal objects', () {
      const a = RecoveryOptions.retryable;
      const b = RecoveryOptions.retryable;

      expect(a.hashCode, b.hashCode);
    });

    test('toString works', () {
      expect(
        RecoveryOptions.retryable.toString(),
        contains('isRetryable: true'),
      );
    });
  });
}
