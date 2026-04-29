import 'package:failures/failures.dart';

/// Common read/write port shared by [KeyValueStorage] and [SecureStorage].
///
/// Both storage types provide the same four operations; they differ only in
/// storage semantics (encrypted vs plain) and lifecycle constraints
/// ([KeyValueStorage] adds [KeyValueStorage.clear]).
///
/// Use [StoredValue] for typed object access instead of raw strings.
abstract interface class ReadWriteStorage {
  /// Returns the raw string value for [key], or `null` if absent.
  ///
  /// Throws [PersistenceFailure] with [FailureCode.readFailed] on error.
  Future<String?> read(String key);

  /// Persists [value] under [key], overwriting any existing value.
  ///
  /// Throws [PersistenceFailure] with [FailureCode.writeFailed] on error.
  Future<void> write(String key, String value);

  /// Removes the entry for [key]. No-op if [key] is absent.
  ///
  /// Throws [PersistenceFailure] with [FailureCode.deleteFailed] on error.
  Future<void> remove(String key);

  /// Returns `true` if [key] exists in storage.
  ///
  /// Throws [PersistenceFailure] with [FailureCode.readFailed] on error.
  Future<bool> contains(String key);
}
