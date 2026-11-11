import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firestore_storage/src/firestore_failure_mapper.dart';
import 'package:firestore_storage/src/models/resolved_snapshot.dart';
import 'package:firestore_storage/src/models/write_operation.dart';
import 'package:firestore_storage/src/types/firestore_types.dart';

/// Firestore access with a clean, typed API.
///
/// Every method that talks to Firestore catches [FirebaseException] and
/// rethrows it as a [Failure] via `mapFirestoreFailure` — callers never see
/// a raw Firestore error code. Methods that don't touch Firestore at all
/// (e.g. [query] when called without a required [DocumentSnapshotTransformer])
/// still throw a plain [ArgumentError]/[StateError]: those are caller
/// mistakes, not Firestore failures, so they aren't wrapped.
class FirestoreService {
  /// Creates a [FirestoreService]. Pass [firestore] to use an instance
  /// other than [FirebaseFirestore.instance] (e.g. a test fake).
  FirestoreService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ── CRUD ──────────────────────────────────────────────────────────────

  /// Creates a document in [collection].
  ///
  /// Creates at [id] if given, otherwise at an auto-generated ID. Returns
  /// the document's ID.
  Future<DocumentId> create({
    required CollectionPath collection,
    required DocumentData data,
    DocumentId? id,
    WriteOptions options = const WriteOptions(),
  }) async {
    try {
      final docRef = id != null ? _firestore.collection(collection).doc(id) : _firestore.collection(collection).doc();

      await docRef.set(
        data,
        options.merge
            ? (options.mergeFields != null ? SetOptions(mergeFields: options.mergeFields!) : SetOptions(merge: true))
            : null,
      );

      return docRef.id;
    } on FirebaseException catch (e, st) {
      throw mapFirestoreFailure(e, st);
    }
  }

  /// Reads the document at [path].
  Future<Snapshot> read({
    required DocumentPath path,
    ServerTimestampBehavior serverTimestampBehavior = ServerTimestampBehavior.none,
  }) async {
    try {
      return await _firestore.doc(path).get(GetOptions(serverTimestampBehavior: serverTimestampBehavior));
    } on FirebaseException catch (e, st) {
      throw mapFirestoreFailure(e, st);
    }
  }

  /// Updates fields in the document at [path]. [data] keys may use dot
  /// notation to address nested fields.
  Future<void> update({required DocumentPath path, required DocumentData data}) async {
    try {
      // The Firestore SDK's update() has no serverTimestampBehavior option.
      await _firestore.doc(path).update(data);
    } on FirebaseException catch (e, st) {
      throw mapFirestoreFailure(e, st);
    }
  }

  /// Deletes the document at [path].
  Future<void> delete({required DocumentPath path}) async {
    try {
      await _firestore.doc(path).delete();
    } on FirebaseException catch (e, st) {
      throw mapFirestoreFailure(e, st);
    }
  }

  /// Queries [collection] per [options].
  ///
  /// [transformer] converts each matching document into a [T]. If omitted,
  /// [T] must itself be [DocumentData] (i.e. `Map<String, dynamic>`).
  ///
  /// Throws [StateError] — not a [Failure] — if [transformer] is omitted
  /// and [T] isn't [DocumentData]: that's a caller mistake, not a Firestore
  /// failure.
  Future<List<T>> query<T extends DocumentData?>({
    required CollectionPath collection,
    QueryOptions options = const QueryOptions(),
    DocumentSnapshotTransformer<T>? transformer,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _buildQuery(collection, options).get();
    } on FirebaseException catch (e, st) {
      throw mapFirestoreFailure(e, st);
    }

    if (transformer != null) {
      return snapshot.docs.map((doc) => transformer(doc)).toList();
    }
    if (T == DocumentData) {
      return snapshot.docs.map((doc) => doc.data() as T).toList();
    }
    throw StateError('transformer is required for type $T');
  }

  /// Queries [collection] per [options], returning at most [pageSize]
  /// documents starting after [nextPageToken] (pass the previous page's
  /// `lastDocument` to continue).
  Future<PaginatedResult<PaginatedSnapshot>> queryPaginated({
    required CollectionPath collection,
    QueryOptions options = const QueryOptions(),
    required int pageSize,
    DocumentSnapshot? nextPageToken,
  }) async {
    try {
      var query = _buildQuery(collection, options).limit(pageSize);
      if (nextPageToken != null) {
        query = query.startAfterDocument(nextPageToken);
      }

      final snapshot = await query.get();
      final hasMore = snapshot.docs.length == pageSize;

      return PaginatedResult<PaginatedSnapshot>(
        items: snapshot.docs,
        lastDocument: hasMore ? snapshot.docs.last : null,
        hasMore: hasMore,
      );
    } on FirebaseException catch (e, st) {
      throw mapFirestoreFailure(e, st);
    }
  }

  // ── Real-time updates ────────────────────────────────────────────────

  /// Watches the document at [path] for changes.
  ///
  /// The returned stream's error events are [Failure]s, not raw
  /// [FirebaseException]s.
  Stream<T?> watchDocument<T extends DocumentData?>({
    required DocumentPath path,
    bool includeMetadataChanges = false,
    DocumentSnapshotTransformer<T>? transformer,
  }) {
    final stream = _firestore.doc(path).snapshots(includeMetadataChanges: includeMetadataChanges);

    return stream
        .map((snapshot) {
          if (transformer != null) {
            return snapshot.exists ? transformer(snapshot) : null;
          }
          return snapshot.data() as T?;
        })
        .handleError(
          (Object error, StackTrace stackTrace) => throw mapFirestoreFailure(error as FirebaseException, stackTrace),
          test: (error) => error is FirebaseException,
        );
  }

  /// Watches [collection] for changes, per [options].
  ///
  /// The returned stream's error events are [Failure]s, not raw
  /// [FirebaseException]s.
  Stream<List<T>> watchCollection<T extends DocumentData?>({
    required CollectionPath collection,
    QueryOptions options = const QueryOptions(),
    bool includeMetadataChanges = false,
    DocumentSnapshotTransformer<T>? transformer,
  }) {
    final query = _buildQuery(collection, options);

    return query.snapshots(includeMetadataChanges: includeMetadataChanges).map((snapshot) {
      if (transformer != null) {
        return snapshot.docs.map((doc) => transformer(doc)).toList();
      }
      return snapshot.docs.map((doc) => doc.data() as T).toList();
    }).handleError(
      (Object error, StackTrace stackTrace) => throw mapFirestoreFailure(error as FirebaseException, stackTrace),
      test: (error) => error is FirebaseException,
    );
  }

  // ── Batch operations ─────────────────────────────────────────────────

  /// Executes [operations] as one or more Firestore batches.
  ///
  /// When [BatchOptions.maxBatchSize] is set, operations are chunked into
  /// separate commits of that size; [BatchOptions.isAtomic] then applies
  /// per chunk, not across the whole list. [onProgress] is called after
  /// each operation is added to its batch (not after each commit).
  ///
  /// Returns the document references touched, in [operations] order.
  Future<List<DocumentReference<DocumentData>>> batchWrite({
    required List<WriteOperation> operations,
    BatchOptions options = const BatchOptions(),
    void Function(int completed, int total)? onProgress,
  }) async {
    try {
      var batch = _firestore.batch();
      final docRefs = <DocumentReference<DocumentData>>[];

      for (var i = 0; i < operations.length; i++) {
        final op = operations[i];
        final docRef = _firestore.doc(op.path);
        docRefs.add(docRef);

        switch (op.type) {
          case WriteOperationType.create:
            batch.set(docRef, op.data!);
          case WriteOperationType.update:
            batch.update(docRef, op.data!);
          case WriteOperationType.delete:
            batch.delete(docRef);
        }

        onProgress?.call(i + 1, operations.length);

        final chunkBoundary = options.maxBatchSize != null && (i + 1) % options.maxBatchSize! == 0;
        if (chunkBoundary) {
          await batch.commit();
          batch = _firestore.batch();
        }
      }

      final lastChunkAlreadyCommitted =
          options.maxBatchSize != null && operations.length % options.maxBatchSize! == 0;
      if (options.isAtomic || !lastChunkAlreadyCommitted) {
        await batch.commit();
      }

      return docRefs;
    } on FirebaseException catch (e, st) {
      throw mapFirestoreFailure(e, st);
    }
  }

  // ── Transactions ──────────────────────────────────────────────────────

  /// Runs [handler] as a Firestore transaction, retrying up to
  /// [maxAttempts] times (with exponential backoff) on failure, or until
  /// [timeout] elapses if given.
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) handler, {
    int maxAttempts = 5,
    Duration? timeout,
  }) async {
    var attempts = 0;
    final startTime = DateTime.now();

    while (true) {
      try {
        return timeout != null
            ? await _firestore.runTransaction<T>(handler, timeout: timeout)
            : await _firestore.runTransaction<T>(handler);
      } on FirebaseException catch (e, st) {
        attempts++;
        final timedOut = timeout != null && DateTime.now().difference(startTime) >= timeout;
        if (attempts >= maxAttempts || timedOut) {
          throw mapFirestoreFailure(e, st);
        }
        await Future<void>.delayed(Duration(milliseconds: 100 * (1 << attempts)));
      }
    }
  }

  // ── Document references ──────────────────────────────────────────────

  /// Creates a document in [collection] with [data], attaching
  /// [DocumentReference]s for the paths listed in [refs] (a map of field
  /// name to one or more [DocumentPath] or [DocumentReference] values).
  Future<DocumentReference> createWithDocumentReference({
    required CollectionPath collection,
    required Map<String, dynamic> data,
    Map<String, List<dynamic>> refs = const {},
    String? docId,
  }) async {
    try {
      final collectionRef = _firestore.collection(collection);
      final newData = Map<String, dynamic>.from(data);

      refs.forEach((field, paths) {
        newData[field] = paths.map((p) {
          if (p is String) return _firestore.doc(p);
          if (p is DocumentReference) return p;
          throw ArgumentError('refs[$field] must be a String path or a DocumentReference');
        }).toList();
      });

      final docRef = docId != null ? collectionRef.doc(docId) : collectionRef.doc();
      await docRef.set(newData);
      return docRef;
    } on FirebaseException catch (e, st) {
      throw mapFirestoreFailure(e, st);
    }
  }

  /// Reads the document at [path] and resolves its [DocumentReference]
  /// fields listed in [fieldsToResolve] into their target documents' data
  /// (recursively, for list-of-reference fields). Returns `null` if the
  /// document doesn't exist.
  Future<ResolvedSnapshot<Snapshot>?> getWithResolvedReferences({
    required DocumentPath path,
    required List<String> fieldsToResolve,
  }) async {
    try {
      final snap = await read(path: path);
      if (!snap.exists) return null;

      final data = Map<String, dynamic>.from(snap.data()!)..['id'] = snap.id;
      final resolved = await _resolveReferences(data, fieldsToResolve);

      return ResolvedSnapshot(snap, resolved);
    } on FirebaseException catch (e, st) {
      throw mapFirestoreFailure(e, st);
    }
  }

  /// Adds or removes [targetPath] from the [DocumentReference] array
  /// field [field] on the document at [path].
  Future<void> updateDocumentReferences({
    required DocumentPath path,
    required String field,
    required DocumentPath targetPath,
    bool add = true,
  }) async {
    try {
      final targetRef = _firestore.doc(targetPath);
      await _firestore.doc(path).update({
        field: add ? FieldValue.arrayUnion([targetRef]) : FieldValue.arrayRemove([targetRef]),
      });
    } on FirebaseException catch (e, st) {
      throw mapFirestoreFailure(e, st);
    }
  }

  /// Like [queryPaginated], but also resolves each result's
  /// [DocumentReference] fields listed in [fieldsToResolve].
  Future<PaginatedResult<ResolvedSnapshot<PaginatedSnapshot>>> queryPaginatedWithResolvedReferences({
    required CollectionPath collection,
    QueryOptions options = const QueryOptions(),
    required int pageSize,
    DocumentSnapshot? nextPageToken,
    List<String> fieldsToResolve = const [],
  }) async {
    try {
      var query = _buildQuery(collection, options).limit(pageSize);
      if (nextPageToken != null) {
        query = query.startAfterDocument(nextPageToken);
      }

      final snapshot = await query.get();
      final hasMore = snapshot.docs.length == pageSize;

      final resolvedDocs = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = Map<String, dynamic>.from(doc.data())..['id'] = doc.id;
          final resolved = await _resolveReferences(data, fieldsToResolve);
          return ResolvedSnapshot(doc, resolved);
        }),
      );

      return PaginatedResult<ResolvedSnapshot<PaginatedSnapshot>>(
        items: resolvedDocs,
        lastDocument: hasMore ? snapshot.docs.last : null,
        hasMore: hasMore,
      );
    } on FirebaseException catch (e, st) {
      throw mapFirestoreFailure(e, st);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  Query<Map<String, dynamic>> _applyWhereCondition<T>(
    Query<Map<String, dynamic>> query,
    WhereCondition<T> condition,
  ) {
    return switch (condition.operator) {
      WhereOperator.lessThan => query.where(condition.field, isLessThan: condition.value),
      WhereOperator.lessThanOrEqualTo => query.where(condition.field, isLessThanOrEqualTo: condition.value),
      WhereOperator.isEqualTo => query.where(condition.field, isEqualTo: condition.value),
      WhereOperator.isNotEqualTo => query.where(condition.field, isNotEqualTo: condition.value),
      WhereOperator.isGreaterThan => query.where(condition.field, isGreaterThan: condition.value),
      WhereOperator.isGreaterThanOrEqualTo => query.where(condition.field, isGreaterThanOrEqualTo: condition.value),
      WhereOperator.arrayContains => query.where(condition.field, arrayContains: condition.value),
      WhereOperator.arrayContainsAny => query.where(condition.field, arrayContainsAny: condition.value as List<T>),
      WhereOperator.inList => query.where(condition.field, whereIn: condition.value as List<T>),
      WhereOperator.notInList => query.where(condition.field, whereNotIn: condition.value as List<T>),
      WhereOperator.isNull => query.where(condition.field, isNull: true),
      WhereOperator.isNotNull => query.where(condition.field, isNull: false),
    };
  }

  Query<Map<String, dynamic>> _buildQuery(CollectionPath collection, QueryOptions options) {
    Query<Map<String, dynamic>> query = _firestore.collection(collection);

    for (final condition in options.whereConditions ?? const []) {
      query = _applyWhereCondition(query, condition);
    }
    for (final order in options.orderBy ?? const []) {
      query = query.orderBy(order.field, descending: order.descending);
    }
    if (options.limit != null) query = query.limit(options.limit!);
    if (options.startAfter != null) query = query.startAfterDocument(options.startAfter!);
    if (options.endBefore != null) query = query.endBeforeDocument(options.endBefore!);

    return query;
  }

  Future<Map<String, dynamic>> _resolveReferences(Map<String, dynamic> data, List<String> fieldsToResolve) async {
    final resolvedData = Map<String, dynamic>.from(data);

    for (final field in fieldsToResolve) {
      if (!resolvedData.containsKey(field)) continue;
      final value = resolvedData[field];

      if (value is DocumentReference) {
        final snap = await value.get();
        resolvedData[field] = {'id': snap.id, ...?snap.data() as Map<String, dynamic>?};
      } else if (value is List) {
        resolvedData[field] = await Future.wait(
          value.map((item) async {
            if (item is DocumentReference) {
              final snap = await item.get();
              final childData = {'id': snap.id, ...?snap.data() as Map<String, dynamic>?};
              return _resolveReferences(childData, fieldsToResolve);
            }
            if (item is Map<String, dynamic>) {
              return _resolveReferences(item, fieldsToResolve);
            }
            return item;
          }),
        );
      }
    }

    return resolvedData;
  }
}
