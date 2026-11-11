/// Firestore access with a clean, typed API.
///
/// Unlike importing `cloud_firestore` directly, errors surface as [Failure]
/// (see `package:failures/failures.dart`), not raw `FirebaseException`.
///
/// This barrel deliberately does NOT re-export the whole `cloud_firestore`
/// SDK — only the specific types that appear in [FirestoreService]'s public
/// signatures, so callers aren't tempted to reach past the service for raw
/// SDK access.
library;

export 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, DocumentSnapshot, QueryDocumentSnapshot, ServerTimestampBehavior, Transaction;

export 'src/firestore_failure_code.dart';
export 'src/firestore_service.dart';
export 'src/models/resolved_snapshot.dart';
export 'src/models/write_operation.dart';
export 'src/types/firestore_types.dart';
