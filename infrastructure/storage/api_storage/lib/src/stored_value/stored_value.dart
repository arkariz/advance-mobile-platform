import 'package:api_storage/src/models/storage_key.dart';
import 'package:api_storage/src/ports/base/read_write_storage.dart';
import 'package:api_storage/src/serializers/json_serializer.dart';
import 'package:api_storage/src/serializers/storage_serializer.dart';

/// Typed accessor for a single persisted object.
///
/// Composes a [StorageKey], a [StorageSerializer], and a [ReadWriteStorage]
/// so repositories deal with domain types instead of raw JSON strings.
///
/// Works with both [KeyValueStorage] and [SecureStorage] since both implement
/// [ReadWriteStorage].
///
/// ## Quick usage with JSON (recommended)
///
/// ```dart
/// final _tokens = StoredValue.json(
///   key: AuthStorageKeys.tokens,
///   fromJson: Tokens.fromJson,
///   toJson: (t) => t.toJson(),
///   storage: _secureStorage,
/// );
/// ```
///
/// ## Custom serializer
///
/// ```dart
/// final _theme = StoredValue(
///   key: AppStorageKeys.theme,
///   serializer: MyCustomSerializer(),
///   storage: _kvStorage,
/// );
/// ```
///
/// ## Usage in a repository
///
/// ```dart
/// final tokens = await _tokens.read();  // T? — null if absent
/// await _tokens.write(newTokens);
/// await _tokens.remove();
/// ```
final class StoredValue<T> {
  /// Creates a [StoredValue] with an explicit [serializer].
  const StoredValue({
    required StorageKey key,
    required StorageSerializer<T> serializer,
    required ReadWriteStorage storage,
  })  : _key = key,
        _serializer = serializer,
        _storage = storage;

  /// Creates a [StoredValue] that serializes via JSON.
  ///
  /// Shorthand that avoids manually constructing [JsonSerializer]:
  ///
  /// ```dart
  /// final _profile = StoredValue.json(
  ///   key: ProfileStorageKeys.data,
  ///   fromJson: Profile.fromJson,
  ///   toJson: (p) => p.toJson(),
  ///   storage: _kvStorage,
  /// );
  /// ```
  StoredValue.json({
    required StorageKey key,
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
    required ReadWriteStorage storage,
  }) : this(
          key: key,
          serializer: JsonSerializer(fromJson: fromJson, toJson: toJson),
          storage: storage,
        );

  final StorageKey _key;
  final StorageSerializer<T> _serializer;
  final ReadWriteStorage _storage;

  /// Reads and deserializes the stored value.
  ///
  /// Returns `null` if no value has been written for this key.
  /// Throws [PersistenceFailure] on storage or serialization error.
  Future<T?> read() async {
    final raw = await _storage.read(_key.value);
    return raw == null ? null : _serializer.decode(raw);
  }

  /// Serializes and persists [value].
  ///
  /// Throws [PersistenceFailure] on storage or serialization error.
  Future<void> write(T value) => _storage.write(_key.value, _serializer.encode(value));

  /// Removes the stored value. No-op if absent.
  ///
  /// Throws [PersistenceFailure] on storage error.
  Future<void> remove() => _storage.remove(_key.value);

  /// Returns `true` if a value is stored for this key.
  ///
  /// Throws [PersistenceFailure] on storage error.
  Future<bool> exists() => _storage.contains(_key.value);
}
