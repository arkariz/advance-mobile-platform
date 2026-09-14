import 'package:failures/failures.dart';
import 'package:security/src/crypto_failure_code.dart';
import 'package:security/src/encryption/aes.dart';
import 'package:test/test.dart';

void main() {
  // 32 characters for AES-256 (256 bits = 32 bytes)
  const testKey = 'test-secret-key-1234567890-32chars';
  late Aes aes;

  setUp(() {
    aes = Aes(key: testKey);
  });

  group('AES Encryption/Decryption', () {
    test('should encrypt and decrypt text successfully', () {
      const plainText = 'Hello, World!';

      final encrypted = aes.encrypt(plainText);
      final decrypted = aes.decrypt(encrypted);

      expect(encrypted, isNotEmpty);
      expect(decrypted, equals(plainText));
    });

    test('should handle empty string', () {
      const emptyString = '';

      final encrypted = aes.encrypt(emptyString);
      final decrypted = aes.decrypt(encrypted);

      expect(encrypted, equals(''));
      expect(decrypted, equals(emptyString));
    });

    test('should handle special characters', () {
      const specialChars = '!@#\$%^&*()_+{}|:"<>?~`-=[]\\;\',./';

      final encrypted = aes.encrypt(specialChars);
      final decrypted = aes.decrypt(encrypted);

      expect(decrypted, equals(specialChars));
    });

    test('should handle long text', () {
      final longText = 'A' * 1000;

      final encrypted = aes.encrypt(longText);
      final decrypted = aes.decrypt(encrypted);

      expect(decrypted, equals(longText));
    });

    test(
      'throws SecurityFailure with decryptionFailed for invalid ciphertext',
      () {
        expect(
          () => aes.decrypt('not-a-valid-encrypted-string'),
          throwsA(
            isA<SecurityFailure>().having(
              (f) => f.code,
              'code',
              CryptoFailureCode.decryptionFailed,
            ),
          ),
        );
      },
    );

    test('should return empty string for empty encrypted input', () {
      expect(aes.decrypt(''), equals(''));
    });

    test('should handle different key lengths', () {
      final aes128 = Aes(key: '16byte-key-12345');
      final aes192 = Aes(key: '24byte-key-123456789012');
      final aes256 = Aes(key: '32byte-key-1234567890123456789012');

      const testText = 'Test encryption with different key lengths';

      expect(
        aes128.encrypt(testText),
        isNot(equals(aes192.encrypt(testText))),
      );
      expect(
        aes192.encrypt(testText),
        isNot(equals(aes256.encrypt(testText))),
      );

      expect(aes128.decrypt(aes128.encrypt(testText)), equals(testText));
      expect(aes192.decrypt(aes192.encrypt(testText)), equals(testText));
      expect(aes256.decrypt(aes256.encrypt(testText)), equals(testText));
    });

    test('different keys should produce different encrypted outputs', () {
      const plainText = 'Hello, World!';
      final aes2 = Aes(key: 'different-secret-key-1234567890-32chars');

      final encrypted1 = aes.encrypt(plainText);
      final encrypted2 = aes2.encrypt(plainText);

      expect(encrypted1, isNot(equals(encrypted2)));
    });

    test('throws ArgumentError for an empty key', () {
      expect(() => Aes(key: ''), throwsArgumentError);
    });
  });
}
