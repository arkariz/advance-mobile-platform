// PersistenceFailure is a domain type, not an Exception/Error subclass by design.
// ignore_for_file: only_throw_errors

import 'dart:convert';

import 'package:api_storage/src/failure_codes/storage_failure_code.dart';
import 'package:api_storage/src/serializers/storage_serializer.dart';
import 'package:failures/failures.dart';

/// A [StorageSerializer] that encodes/decodes objects via JSON.
///
/// Requires caller-supplied [fromJson] and [toJson] functions so this
/// class stays free of code-generation dependencies:
///
/// ```dart
/// final serializer = JsonSerializer<UserProfile>(
///   fromJson: UserProfile.fromJson,
///   toJson:   (p) => p.toJson(),
/// );
///
/// final stored  = serializer.encode(profile);   // → JSON string
/// final profile = serializer.decode(stored);    // → UserProfile
/// ```
final class JsonSerializer<T> implements StorageSerializer<T> {
  /// Creates a [JsonSerializer] with caller-supplied [fromJson] and [toJson]
  /// functions to avoid code-generation dependencies.
  const JsonSerializer({
    required T Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(T) toJson,
  })  : _fromJson = fromJson,
        _toJson = toJson;

  final T Function(Map<String, dynamic>) _fromJson;
  final Map<String, dynamic> Function(T) _toJson;

  @override
  String encode(T value) {
    try {
      return jsonEncode(_toJson(value));
    } catch (e, st) {
      throw PersistenceFailure(
        code: StorageFailureCode.serializationFailed,
        message: 'Failed to encode $T to JSON: $e',
        details: FailureDetails(cause: e, stackTrace: st),
      );
    }
  }

  @override
  T decode(String source) {
    try {
      final json = jsonDecode(source) as Map<String, dynamic>;
      return _fromJson(json);
    } catch (e, st) {
      throw PersistenceFailure(
        code: StorageFailureCode.serializationFailed,
        message: 'Failed to decode $T from JSON: $e',
        details: FailureDetails(cause: e, stackTrace: st),
      );
    }
  }
}
