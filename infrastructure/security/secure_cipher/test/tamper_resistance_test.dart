import 'dart:convert';
import 'dart:typed_data';

import 'package:failures/failures.dart';
import 'package:secure_cipher/secure_cipher.dart';
// Internal on purpose: this test shows what the unauthenticated primitive does.
import 'package:secure_cipher/src/encryption/aes.dart';
import 'package:test/test.dart';

/// Why [SecureCipher] exists, as an executable argument.
///
/// AES-CBC alone has no integrity check. Flipping a bit of the IV flips the
/// same bit of the first plaintext block, and decryption still "succeeds".
void main() {
  const key = 'demo-key-0123456789-abcdefghijkl'; // exactly 32 bytes
  // The first AES block is the first 16 bytes: "transfer:100.00 ".
  const message = 'transfer:100.00 to:alice';
  // Byte 9 is the '1' of 100.00 (0x31). XOR 0x08 turns it into '9' (0x39).
  const flippedIndex = 9;
  const flipMask = 0x08;

  test(
    'bare AES-CBC accepts a bit-flipped IV and returns altered plaintext',
    () {
      final aes = Aes(key: key);
      final raw = Uint8List.fromList(base64.decode(aes.encrypt(message)));

      raw[flippedIndex] ^= flipMask;

      expect(aes.decrypt(base64.encode(raw)), 'transfer:900.00 to:alice');
    },
  );

  test('SecureCipher rejects the same bit-flip', () {
    final cipher = SecureCipher(key: key);
    final token = cipher.encrypt(message);
    final tag = token.substring(0, 64);
    final body = Uint8List.fromList(base64.decode(token.substring(64)));

    // An attacker can alter the ciphertext but cannot recompute the tag
    // without the key, so they can only send the old tag with the new body.
    body[flippedIndex] ^= flipMask;

    expect(
      () => cipher.decrypt('$tag${base64.encode(body)}'),
      throwsA(
        isA<SecurityFailure>().having(
          (f) => f.code,
          'code',
          FailureCode.tamperedPayload,
        ),
      ),
    );
  });

  test('a tampered payload and a wrong key are indistinguishable', () {
    final cipher = SecureCipher(key: key);
    final token = cipher.encrypt(message);
    final tampered = '${token.substring(0, 64)}A${token.substring(65)}';
    final wrongKey = SecureCipher(key: 'another-key-0123456789-abcdefghi');

    SecurityFailure failureOf(void Function() body) {
      try {
        body();
      } on SecurityFailure catch (f) {
        return f;
      }
      fail('expected a SecurityFailure');
    }

    final fromTamper = failureOf(() => cipher.decrypt(tampered));
    final fromWrongKey = failureOf(() => wrongKey.decrypt(token));

    expect(fromTamper.code, fromWrongKey.code);
    expect(fromTamper.message, fromWrongKey.message);
  });

  test('keys that differ only beyond byte 32 do not interoperate', () {
    // The AES layer normalises keys to 32 bytes, so it would ignore the
    // difference. The HMAC covers the whole key, so SecureCipher notices.
    final a = SecureCipher(key: '${'A' * 32}X');
    final b = SecureCipher(key: '${'A' * 32}Y');

    expect(
      () => b.decrypt(a.encrypt(message)),
      throwsA(isA<SecurityFailure>()),
    );
  });
}
