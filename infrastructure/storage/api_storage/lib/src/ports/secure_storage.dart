import 'package:api_storage/src/ports/base/read_write_storage.dart';

/// Port for encrypted, credential-safe key-value persistence.
///
/// Extends [ReadWriteStorage]. `clear()` is intentionally absent:
/// wiping all credentials at once is an irreversible, catastrophic action.
/// Callers must explicitly remove individual keys via [ReadWriteStorage.remove].
///
/// For typed object access, use [StoredValue].
abstract interface class SecureStorage implements ReadWriteStorage {}
