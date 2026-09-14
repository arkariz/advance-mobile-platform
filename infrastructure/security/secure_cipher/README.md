# secure_cipher

Authenticated encryption and keyed hashing.

---

## Why this package

Symmetric encryption is easy to misuse. Plain AES-CBC has no integrity
check, so a tampered or corrupted ciphertext can decrypt "successfully"
into garbage instead of failing loudly — the padding-oracle and
bit-flipping classes of attack both rely on exactly this gap. This
package closes that gap by construction, not by convention: there is one
public class, and it is the safe one.

## Usage

```dart
import 'package:secure_cipher/secure_cipher.dart';

final cipher = SecureCipher(key: sessionKey);

final token = cipher.encrypt(sensitiveValue);
// ... store or transmit `token` ...

final original = cipher.decrypt(token);
// throws SecurityFailure(code: FailureCode.tamperedPayload) if `token`
// was corrupted, tampered with, or decrypted with the wrong key.
```

`SecureCipher` combines AES-256-CBC with an HMAC-SHA256 integrity tag
(encrypt-then-MAC) and verifies the tag in constant time before
decrypting. Every failure — a bad key, a malformed payload, a tampered
ciphertext — surfaces as a thrown [`SecurityFailure`][failures] carrying
a [`CryptoFailureCode`] or the shared `FailureCode.tamperedPayload`,
never as a silently wrong string.

[failures]: ../../../core/failures

## What's intentionally not exposed

An earlier, standalone version of this logic exposed `Aes` and
`HmacHash` as separate public classes, plus a GetIt-based `AesKey`/
`securityModule()` wiring step. None of that is part of this package's
public API:

- `Aes` and `HmacHash` are still here as internal implementation detail,
  but constructing them directly gives you *unauthenticated* AES or a
  bare HMAC — the exact footgun `SecureCipher` exists to prevent.
- The GetIt module is gone entirely. `SecureCipher(key: ...)` takes its
  key explicitly, the same way this monorepo's other adapters take their
  dependencies as constructor parameters — there's no hidden global
  registration to set up first, and no way to end up asking "which key
  is active right now?" without an answer in the caller's own code.

If you need raw unauthenticated AES or a bare HMAC for interop with an
external system, that's a deliberate exception to make in your own
call site — not something this package should make convenient by
default.
