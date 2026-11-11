/// Represents a single write operation to perform as part of a
/// [FirestoreService.batchWrite] call.
class WriteOperation {
  WriteOperation._({required this.type, required this.path, this.data});

  /// Creates a document at [path] with [data].
  factory WriteOperation.create({
    required String path,
    required Map<String, dynamic> data,
  }) => WriteOperation._(type: WriteOperationType.create, path: path, data: data);

  /// Updates the document at [path] with [data].
  factory WriteOperation.update({
    required String path,
    required Map<String, dynamic> data,
  }) => WriteOperation._(type: WriteOperationType.update, path: path, data: data);

  /// Deletes the document at [path].
  factory WriteOperation.delete(String path) =>
      WriteOperation._(type: WriteOperationType.delete, path: path);

  /// The kind of write to perform.
  final WriteOperationType type;

  /// The target document path.
  final String path;

  /// The data to write, for [WriteOperationType.create] and
  /// [WriteOperationType.update].
  final Map<String, dynamic>? data;
}

/// The kind of write [WriteOperation] performs.
enum WriteOperationType {
  /// Create a new document.
  create,

  /// Update an existing document.
  update,

  /// Delete a document.
  delete,
}
