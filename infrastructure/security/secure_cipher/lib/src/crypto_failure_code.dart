import 'package:failures/failures.dart';

/// Crypto-specific [FailureCode] constants.
///
/// Extend this pattern to define feature-specific security codes without
/// modifying [FailureCode] in `core/failures`. For tampering/integrity
/// failures, prefer the existing [FailureCode.tamperedPayload] instead of
/// adding a new code here — [SecureCipher] already does this.
abstract final class CryptoFailureCode {
  /// AES encryption failed — invalid input or an internal cipher error.
  static const encryptionFailed = FailureCode('CRYPTO_ENCRYPTION_FAILED');

  /// AES decryption failed — malformed ciphertext or wrong key.
  static const decryptionFailed = FailureCode('CRYPTO_DECRYPTION_FAILED');

  /// HMAC computation failed.
  static const hashingFailed = FailureCode('CRYPTO_HASHING_FAILED');
}
