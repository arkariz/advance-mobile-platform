import 'package:failures/failures.dart';

import 'package:secure_cipher/src/encryption/aes.dart';
import 'package:secure_cipher/src/hash/hmac_hash.dart';

/// Authenticated encryption: AES-256-CBC + HMAC-SHA256 (encrypt-then-MAC).
///
/// This is the recommended — and only exported — entry point for this
/// package. Plain AES-CBC has no integrity check, so a tampered or
/// corrupted ciphertext can decrypt "successfully" into garbage instead
/// of failing loudly. [SecureCipher] prepends a fixed-length HMAC-SHA256
/// tag to the ciphertext and verifies it, in constant time, before
/// decrypting — so tampering, corruption, or a wrong key always surfaces
/// as a thrown [SecurityFailure], never as silently wrong output.
///
/// ```dart
/// final cipher = SecureCipher(key: sessionKey);
///
/// final token = cipher.encrypt(sensitiveValue);
/// // ... store or transmit `token` ...
///
/// final original = cipher.decrypt(token);
/// // throws SecurityFailure(code: FailureCode.tamperedPayload) if `token`
/// // was corrupted, tampered with, or decrypted with the wrong key.
/// ```
///
/// There is exactly one class to reach for here — no separate `Aes`,
/// `HmacHash`, or DI wiring to understand first.
final class SecureCipher {
  /// Creates a [SecureCipher] keyed by [key]. The same [key] must be used
  /// to decrypt what was encrypted with it.
  SecureCipher({required this.key})
    : _aes = Aes(key: key),
      _hmac = HmacHash(key: key);

  /// The shared secret backing both encryption and integrity checks.
  final String key;

  final Aes _aes;
  final HmacHash _hmac;

  /// Length, in hex characters, of an HMAC-SHA256 tag.
  static const int _tagLength = 64;

  /// Encrypts [plainText] and prepends an HMAC-SHA256 integrity tag.
  ///
  /// Throws [SecurityFailure] (via the underlying AES/HMAC primitives) if
  /// encryption fails.
  String encrypt(String plainText) {
    final cipherText = _aes.encrypt(plainText);
    final tag = _hmac.compute(plainText: cipherText);
    return '$tag$cipherText';
  }

  /// Verifies the integrity tag and decrypts the payload.
  ///
  /// Throws [SecurityFailure] with [FailureCode.tamperedPayload] if the
  /// payload is too short to contain a tag or the tag doesn't match
  /// (tampering, corruption, or a wrong key) — intentionally the same
  /// failure in every case, since distinguishing "tampered" from "wrong
  /// key" would leak which one occurred to an attacker.
  String decrypt(String payload) {
    // Note: a payload of exactly [_tagLength] is valid — it's the token
    // produced by encrypting an empty string, which is just the tag with
    // no ciphertext after it (see [Aes.encrypt]'s empty-input short
    // circuit). Only a payload shorter than a full tag is malformed.
    if (payload.length < _tagLength) {
      throw const SecurityFailure(
        code: FailureCode.tamperedPayload,
        message: 'Payload too short to contain a valid integrity tag',
      );
    }
    final tag = payload.substring(0, _tagLength);
    final cipherText = payload.substring(_tagLength);
    final expectedTag = _hmac.compute(plainText: cipherText);

    if (!_constantTimeEquals(tag, expectedTag)) {
      throw const SecurityFailure(
        code: FailureCode.tamperedPayload,
        message:
            'HMAC verification failed — payload tampered, corrupted, or '
            'decrypted with the wrong key',
      );
    }
    return _aes.decrypt(cipherText);
  }

  /// Compares two equal-length strings without early-exit, so tag
  /// verification doesn't leak match progress through timing.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
