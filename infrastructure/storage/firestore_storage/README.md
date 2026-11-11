# firestore_storage

Firestore access with a clean, typed API.

---

## Why this package

`cloud_firestore` is the only real backend behind it, so this package
doesn't invent an abstract storage port the way `api_storage` does for
key-value storage (there's nothing to swap it for, and Firestore's query/
transaction/reference-resolution surface doesn't fit a key-value shape
anyway). What it does fix is everything that was wrong with depending on
`FirebaseException` directly: callers shouldn't need to know Firestore's
gRPC error codes, and a barrel that re-exports the entire SDK invites
reaching past the service for raw access.

## Usage

```dart
import 'package:firestore_storage/firestore_storage.dart';

final service = FirestoreService();

try {
  final id = await service.create(
    collection: 'users',
    data: {'name': 'Rizky'},
  );
} on Failure catch (failure) {
  // failure is a NetworkFailure, AuthorizationFailure, PersistenceFailure,
  // etc. — never a raw FirebaseException.
}
```

Every method that talks to Firestore catches `FirebaseException` and
rethrows it as a [`Failure`][failures] via `mapFirestoreFailure`, which
reuses an existing `FailureCode` where one already fits (e.g. Firestore's
`unavailable` becomes `NetworkFailure(code: FailureCode.noConnection)`)
and falls back to a Firestore-specific `FirestoreFailureCode` otherwise.
The two `watch*` methods report the same way on their stream's error
channel, not just on the initial `Future`.

[failures]: ../../../core/failures

## What's intentionally not exposed

This is adapted from an earlier, standalone `firestore` package. Three
things from that version are deliberately not part of this package:

- **The blanket SDK re-export.** The original barrel exported the whole
  of `package:cloud_firestore/cloud_firestore.dart`. This one exports
  only the specific SDK types that actually appear in `FirestoreService`'s
  public signatures (`DocumentReference`, `DocumentSnapshot`,
  `QueryDocumentSnapshot`, `ServerTimestampBehavior`, `Transaction`) —
  callers use the service, not the SDK underneath it.
- **The GetIt-based `FirestoreModule`.** Like `secure_cipher`'s dropped
  `securityModule()`, this required calling `.configure()` before
  `.firestoreService()` would work, with a confusing `StateError` if you
  forgot. `FirestoreService()` takes its dependency (optionally, for
  tests) as a constructor parameter instead.
- **Unused dependencies and dead code.** `firebase_core`, `logger`,
  `provider`, `json_annotation`, and `mocktail` were listed as
  dependencies but unused anywhere in the original package; the
  `QueryBuilder`, `QuerySnapshotTransformer`, `BatchOperation`, and
  `ErrorHandler` typedefs plus `TransactionOptions` were defined but
  never referenced (`TransactionOptions` didn't even match
  `runTransaction`'s real `maxAttempts`/`timeout` parameters). None of
  these are carried over.

Two raw throws remain unwrapped on purpose: `query`'s `StateError` when
no transformer is given for a non-`DocumentData` type, and
`createWithDocumentReference`'s `ArgumentError` for a bad `refs` entry.
Both are caller mistakes, not Firestore failures, so they aren't folded
into the `Failure` model.

## Bugs fixed during the port

Three behavioral bugs in the original package, found while adding the
`Failure`-wrapping above and fixed rather than carried over — see
`CHANGELOG.md` for the full detail:

- `query`'s no-transformer fallback used `T is Map<String, dynamic>`,
  which tests a reified `Type` object, not the actual generic type — it
  always evaluated to `false` and so always threw, even when `T` really
  was `DocumentData`.
- `watchDocument` ran its stream through a `withConverter` that called
  `doc.data()!`, so watching a document that doesn't exist crashed the
  stream instead of emitting `null`.
- `runTransaction`'s retry loop caught *any* exception from the
  transaction handler, not just `FirebaseException` — an application
  bug inside the handler would get silently retried and swallowed
  instead of propagating.
