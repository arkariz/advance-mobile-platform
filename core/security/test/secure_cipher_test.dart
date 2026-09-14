import 'package:failures/failures.dart';
import 'package:security/security.dart';
import 'package:test/test.dart';

void main() {
  const key = 'test-secret-key-1234567890-32chars';
  late SecureCipher cipher;

  setUp(() => cipher = SecureCipher(key: key));

  group('SecureCipher', () {
    test('round-trips plain text', () {
      const plainText = 'Hello, World!';
      final token = cipher.encrypt(plainText);
      expect(cipher.decrypt(token), equals(plainText));
    });

    test('round-trips an empty string', () {
      final token = cipher.encrypt('');
      expect(cipher.decrypt(token), equals(''));
    });

    test('round-trips long text', () {
      final longText = 'A' * 1000;
      final token = cipher.encrypt(longText);
      expect(cipher.decrypt(token), equals(longText));
    });

    test('different plaintexts produce different tokens', () {
      expect(cipher.encrypt('a'), isNot(equals(cipher.encrypt('b'))));
    });

    test('token carries a 64-hex-char tag ahead of the ciphertext', () {
      final token = cipher.encrypt('secret');
      expect(token.length, greaterThan(64));
      expect(RegExp(r'^[0-9a-f]{64}').hasMatch(token), isTrue);
    });

    test(
      'throws SecurityFailure with tamperedPayload on a corrupted token',
      () {
        final token = cipher.encrypt('secret');
        // Flip one character just past the tag, inside the ciphertext.
        final flipped = token[64] == 'A' ? 'B' : 'A';
        final corrupted = token.substring(0, 64) + flipped + token.substring(65);

        expect(
          () => cipher.decrypt(corrupted),
          throwsA(
            isA<SecurityFailure>().having(
              (f) => f.code,
              'code',
              FailureCode.tamperedPayload,
            ),
          ),
        );
      },
    );

    test('throws SecurityFailure when decrypted with the wrong key', () {
      final token = cipher.encrypt('secret');
      final wrongCipher = SecureCipher(key: 'a-completely-different-key-32ch');

      expect(() => wrongCipher.decrypt(token), throwsA(isA<SecurityFailure>()));
    });

    test(
      'throws SecurityFailure with tamperedPayload for a too-short payload',
      () {
        expect(
          () => cipher.decrypt('too-short'),
          throwsA(
            isA<SecurityFailure>().having(
              (f) => f.code,
              'code',
              FailureCode.tamperedPayload,
            ),
          ),
        );
      },
    );
  });
}
