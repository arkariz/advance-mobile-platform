import 'package:cloud_firestore/cloud_firestore.dart';

/// A resolved document snapshot: the raw snapshot plus a data map with any
/// [DocumentReference] fields already resolved to their target document's
/// data (see [FirestoreService.getWithResolvedReferences]).
class ResolvedSnapshot<T extends DocumentSnapshot<Map<String, dynamic>>> {
  /// Creates a [ResolvedSnapshot] wrapping [raw] with its resolved [data].
  ResolvedSnapshot(this.raw, this.data);

  /// The original, unresolved snapshot.
  final T raw;

  /// [raw]'s data with reference fields resolved.
  final Map<String, dynamic> data;

  /// The document ID, forwarded from [raw].
  String get id => raw.id;

  /// The document reference, forwarded from [raw].
  DocumentReference<Map<String, dynamic>> get ref => raw.reference;
}
