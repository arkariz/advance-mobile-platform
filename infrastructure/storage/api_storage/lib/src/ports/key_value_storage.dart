import 'package:api_storage/src/ports/base/read_write_storage.dart';
import 'package:failures/failures.dart';

/// Port for general-purpose key-value persistence.
///
/// Extends [ReadWriteStorage] with [clear] for bulk removal.
/// For typed object access, use [StoredValue].
///
/// All methods throw [PersistenceFailure] on underlying storage errors.
abstract interface class KeyValueStorage implements ReadWriteStorage {
  /// Removes all entries from this storage.
  ///
  /// Throws [PersistenceFailure] with [FailureCode.deleteFailed] on error.
  Future<void> clear();
}
