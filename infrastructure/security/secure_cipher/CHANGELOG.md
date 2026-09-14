## 1.0.1

 - **REFACTOR**: move security -> infrastructure/security/secure_cipher.

## 1.0.0

 - **FEAT**(secure_cipher): initial release — `SecureCipher` (AES-256-CBC + HMAC-SHA256 authenticated encryption) and `CryptoFailureCode`, adapted from an earlier standalone `security` package.
 - **FIX**(secure_cipher): report failures via `SecurityFailure` instead of sentinel strings (`"Failed to decrypt"`) or swallowed exceptions — invalid PKCS7 padding on decrypt is now a thrown failure instead of silently-returned, unstripped output.
 - **BREAKING**: raw `Aes`/`HmacHash` primitives and the GetIt-based `AesKey`/`securityModule()` wiring are no longer part of the public API. Use `SecureCipher` instead.
