import 'package:crypto/crypto.dart';
import 'package:secure_cipher/src/hash/hmac_hash.dart';
import 'package:test/test.dart';

void main() {
  const testKey = 'test-secret-key';
  late HmacHash hmacHash;

  setUp(() {
    hmacHash = HmacHash(key: testKey);
  });

  group('HmacHash', () {
    test('should compute HMAC-SHA256 hash correctly', () {
      const plainText = 'Hello, World!';

      final result = hmacHash.compute(plainText: plainText, hashType: sha256);

      expect(result, isNotEmpty);
      expect(
        result,
        equals(
          '64cc4644ffe2f206e807486fc2cc29de6d9f6f3e86f6c06bdab72f02e6e02c78',
        ),
      );
    });

    test('should compute different hashes for different hash algorithms', () {
      const plainText = 'test message';

      final sha1Result = hmacHash.compute(plainText: plainText, hashType: sha1);
      final sha256Result = hmacHash.compute(
        plainText: plainText,
        hashType: sha256,
      );
      final sha512Result = hmacHash.compute(
        plainText: plainText,
        hashType: sha512,
      );

      expect(sha1Result, isNot(equals(sha256Result)));
      expect(sha256Result, isNot(equals(sha512Result)));
      expect(sha1Result, isNot(equals(sha512Result)));

      expect(sha1Result.length, equals(40));
      expect(sha256Result.length, equals(64));
      expect(sha512Result.length, equals(128));
    });

    test('should handle empty string input', () {
      final result = hmacHash.compute(plainText: '');

      expect(result, isNotEmpty);
      expect(result.length, equals(64));
    });

    test('should handle special characters in input', () {
      const specialChars = '!@#\$%^&*()_+{}|:"<>?~`-=[]\\;\',./';

      final result = hmacHash.compute(plainText: specialChars);

      expect(result, isNotEmpty);
      expect(result.length, equals(64));
    });

    test('should return different hashes for different keys', () {
      const plainText = 'same message';
      final hmacHash2 = HmacHash(key: 'different-secret-key');

      final result1 = hmacHash.compute(plainText: plainText);
      final result2 = hmacHash2.compute(plainText: plainText);

      expect(result1, isNot(equals(result2)));
    });
  });
}
