import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:failures/failures.dart';

import 'package:security/src/crypto_failure_code.dart';

/// Computes an HMAC over UTF-8 text using a keyed hash algorithm.
///
/// Not exported from this package's public barrel — used internally by
/// `SecureCipher` for integrity tagging. Construct it directly only from
/// within this package.
final class HmacHash {
  /// Creates an [HmacHash] keyed by [key].
  HmacHash({required this.key});

  /// The HMAC key.
  final String key;

  /// Returns the hex-encoded HMAC of [plainText] using [hashType]
  /// (defaults to SHA-256).
  ///
  /// Throws [SecurityFailure] with [CryptoFailureCode.hashingFailed] if
  /// computation fails.
  String compute({required String plainText, Hash hashType = sha256}) {
    try {
      final hmac = Hmac(hashType, utf8.encode(key));
      return hmac.convert(utf8.encode(plainText)).toString();
    } catch (e, stackTrace) {
      throw SecurityFailure(
        code: CryptoFailureCode.hashingFailed,
        message: 'HMAC computation failed: $e',
        details: FailureDetails(cause: e, stackTrace: stackTrace),
      );
    }
  }
}
