import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:aes_crypt_null_safe/aes_crypt_null_safe.dart';
import 'package:failures/failures.dart';

import 'package:security/src/crypto_failure_code.dart';

/// Low-level AES-256-CBC encryption with a random IV per call.
///
/// **Not authenticated** — this alone does not detect tampering (see the
/// CBC bit-flipping / padding-oracle class of attacks: a corrupted or
/// tampered ciphertext can still "successfully" decrypt into garbage
/// instead of failing). Prefer `SecureCipher`, which combines this with
/// an HMAC integrity check and is this package's public entry point.
/// [Aes] itself is not exported — construct it only from within this
/// package if you have your own integrity mechanism.
final class Aes {
  /// Creates an [Aes] cipher using [key] (any length; internally
  /// normalized to 32 bytes for AES-256).
  Aes({required this.key}) {
    if (key.isEmpty) {
      throw ArgumentError.value(key, 'key', 'must not be empty');
    }
  }

  /// The encryption key, before internal normalization to 32 bytes.
  final String key;

  static const int _blockSize = 16;
  static const int _ivLength = 16;

  /// Encrypts [plainText], returning base64(iv + ciphertext).
  ///
  /// Throws [SecurityFailure] with [CryptoFailureCode.encryptionFailed]
  /// if encryption fails.
  String encrypt(String plainText) {
    if (plainText.isEmpty) return '';
    try {
      final iv = Uint8List.fromList(
        List.generate(_ivLength, (_) => Random.secure().nextInt(256)),
      );
      final crypt = AesCrypt()
        ..aesSetKeys(_normalizeKey(key), iv)
        ..aesSetMode(AesMode.cbc);

      final padded = _addPkcs7Padding(
        Uint8List.fromList(utf8.encode(plainText)),
        _blockSize,
      );
      final encrypted = crypt.aesEncrypt(padded);

      final result = Uint8List(iv.length + encrypted.length)
        ..setAll(0, iv)
        ..setAll(iv.length, encrypted);
      return base64.encode(result);
    } catch (e, stackTrace) {
      throw SecurityFailure(
        code: CryptoFailureCode.encryptionFailed,
        message: 'AES encryption failed: $e',
        details: FailureDetails(cause: e, stackTrace: stackTrace),
      );
    }
  }

  /// Decrypts a payload produced by [encrypt].
  ///
  /// Throws [SecurityFailure] with [CryptoFailureCode.decryptionFailed]
  /// if the payload is malformed, the key is wrong, or decryption
  /// otherwise fails — including invalid PKCS7 padding, which is
  /// reported as a failure rather than returned unstripped.
  String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    try {
      final data = base64.decode(encryptedText);
      if (data.length < _ivLength) {
        throw const FormatException('ciphertext shorter than IV length');
      }
      final iv = Uint8List.sublistView(data, 0, _ivLength);
      final cipherBytes = Uint8List.sublistView(data, _ivLength);

      final crypt = AesCrypt()
        ..aesSetKeys(_normalizeKey(key), iv)
        ..aesSetMode(AesMode.cbc);

      final padded = crypt.aesDecrypt(cipherBytes);
      return utf8.decode(_removePkcs7Padding(padded));
    } catch (e, stackTrace) {
      throw SecurityFailure(
        code: CryptoFailureCode.decryptionFailed,
        message: 'AES decryption failed: $e',
        details: FailureDetails(cause: e, stackTrace: stackTrace),
      );
    }
  }

  static Uint8List _normalizeKey(String key) {
    final bytes = utf8.encode(key);
    if (bytes.length == 32) return Uint8List.fromList(bytes);
    if (bytes.length < 32) {
      return Uint8List(32)..setRange(0, bytes.length, bytes);
    }
    return Uint8List.sublistView(Uint8List.fromList(bytes), 0, 32);
  }

  static Uint8List _addPkcs7Padding(Uint8List data, int blockSize) {
    final padLength = blockSize - (data.length % blockSize);
    final padded = Uint8List(data.length + padLength)..setAll(0, data);
    for (var i = data.length; i < padded.length; i++) {
      padded[i] = padLength;
    }
    return padded;
  }

  static Uint8List _removePkcs7Padding(Uint8List data) {
    if (data.isEmpty) return data;
    final padLength = data[data.length - 1];
    if (padLength <= 0 || padLength > _blockSize || padLength > data.length) {
      throw const FormatException('invalid PKCS7 padding');
    }
    for (var i = 1; i <= padLength; i++) {
      if (data[data.length - i] != padLength) {
        throw const FormatException('invalid PKCS7 padding');
      }
    }
    return Uint8List.sublistView(data, 0, data.length - padLength);
  }
}
