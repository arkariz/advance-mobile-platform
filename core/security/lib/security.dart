/// Authenticated encryption and keyed hashing.
///
/// Exposes exactly one entry point — [SecureCipher] — plus the failure
/// codes it (and callers extending it) may need to match on. The
/// underlying AES and HMAC primitives are intentionally not exported;
/// see [SecureCipher]'s documentation for why.
library;

export 'src/crypto_failure_code.dart';
export 'src/secure_cipher.dart';
