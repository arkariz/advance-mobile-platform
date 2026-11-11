import 'package:cloud_firestore/cloud_firestore.dart';

/// A document ID.
typedef DocumentId = String;

/// A collection path, e.g. `'users'`.
typedef CollectionPath = String;

/// A full document path, e.g. `'users/123'`.
typedef DocumentPath = String;

/// A document's data.
typedef DocumentData = Map<String, dynamic>;

/// A document snapshot.
typedef Snapshot = DocumentSnapshot<Map<String, dynamic>>;

/// A document snapshot returned from a query.
typedef PaginatedSnapshot = QueryDocumentSnapshot<Map<String, dynamic>>;

/// Transforms a [DocumentSnapshot] into a domain type [T].
typedef DocumentSnapshotTransformer<T> = T Function(Snapshot snapshot);

/// Options for [FirestoreService.query], [FirestoreService.queryPaginated],
/// and [FirestoreService.watchCollection].
class QueryOptions {
  /// Creates a [QueryOptions].
  const QueryOptions({
    this.limit,
    this.orderBy,
    this.whereConditions,
    this.startAfter,
    this.endBefore,
  });

  /// Maximum number of documents to return.
  final int? limit;

  /// Fields to order by, applied in order.
  final List<OrderByOption>? orderBy;

  /// Filters to apply, combined with AND.
  final List<WhereCondition>? whereConditions;

  /// Document to start after, for pagination.
  final DocumentSnapshot? startAfter;

  /// Document to end before, for pagination.
  final DocumentSnapshot? endBefore;
}

/// One `orderBy` clause.
class OrderByOption {
  /// Creates an [OrderByOption] for [field].
  const OrderByOption(this.field, {this.descending = false});

  /// The field to order by.
  final String field;

  /// Whether to sort descending.
  final bool descending;
}

/// One `where` clause.
class WhereCondition<T> {
  /// Creates a [WhereCondition].
  const WhereCondition({required this.field, required this.operator, required this.value});

  /// The field to filter on.
  final String field;

  /// The comparison to apply.
  final WhereOperator operator;

  /// The value to compare against.
  final T value;
}

/// Supported `where` comparisons.
enum WhereOperator {
  /// `<`
  lessThan,

  /// `<=`
  lessThanOrEqualTo,

  /// `==`
  isEqualTo,

  /// `!=`
  isNotEqualTo,

  /// `>`
  isGreaterThan,

  /// `>=`
  isGreaterThanOrEqualTo,

  /// Array field contains the value.
  arrayContains,

  /// Array field contains any of the given values.
  arrayContainsAny,

  /// Field value is one of the given values.
  inList,

  /// Field value is none of the given values.
  notInList,

  /// Field is null.
  isNull,

  /// Field is not null.
  isNotNull,
}

/// Options for [FirestoreService.create].
class WriteOptions {
  /// Creates [WriteOptions].
  const WriteOptions({this.merge = false, this.mergeFields, this.serverTimestampBehavior});

  /// Whether to merge with any existing document instead of overwriting it.
  final bool merge;

  /// When [merge] is true, restricts the merge to these fields.
  final List<String>? mergeFields;

  /// How server timestamps are resolved when reading the written value back.
  final ServerTimestampBehavior? serverTimestampBehavior;
}

/// Options for [FirestoreService.batchWrite].
class BatchOptions {
  /// Creates [BatchOptions].
  const BatchOptions({this.isAtomic = true, this.maxBatchSize});

  /// Whether the whole batch commits atomically.
  final bool isAtomic;

  /// Maximum operations per underlying Firestore batch, chunking larger
  /// operation lists into multiple commits.
  final int? maxBatchSize;
}

/// A page of query results.
class PaginatedResult<T> {
  /// Creates a [PaginatedResult].
  const PaginatedResult({required this.items, this.lastDocument, this.hasMore = false});

  /// The items in this page.
  final List<T> items;

  /// The last document in this page, to pass as `nextPageToken` for the
  /// next page.
  final Snapshot? lastDocument;

  /// Whether a next page is likely available.
  final bool hasMore;
}
