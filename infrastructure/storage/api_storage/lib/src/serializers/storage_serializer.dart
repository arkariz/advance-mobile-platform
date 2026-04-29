/// Bidirectional serializer between a Dart type and a storage [String].
///
/// Implement this interface to add custom serialization strategies
/// (e.g., Protobuf, MessagePack) alongside the bundled [JsonSerializer].
///
/// ```dart
/// final class TokenSerializer implements StorageSerializer<AuthToken> {
///   const TokenSerializer();
///
///   @override
///   String encode(AuthToken value) => jsonEncode(value.toJson());
///
///   @override
///   AuthToken decode(String source) =>
///       AuthToken.fromJson(jsonDecode(source) as Map<String, dynamic>);
/// }
/// ```
abstract interface class StorageSerializer<T> {
  /// Encodes [value] to a [String] suitable for storage.
  ///
  /// Throws [PersistenceFailure] with
  /// [StorageFailureCode.serializationFailed] on error.
  String encode(T value);

  /// Decodes [source] back to a [T].
  ///
  /// Throws [PersistenceFailure] with
  /// [StorageFailureCode.serializationFailed] on error.
  T decode(String source);
}
