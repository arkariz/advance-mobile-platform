// StorageKey is a value-object with final fields; == and hashCode are correct here.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

/// A structured, namespaced storage key.
///
/// Prefer defining keys as constants in a feature-specific class rather than
/// scattering raw strings:
///
/// ```dart
/// abstract final class AuthStorageKeys {
///   static const tokens = StorageKey(namespace: 'auth', name: 'tokens');
///   static const userId = StorageKey(namespace: 'auth', name: 'user_id');
/// }
/// ```
final class StorageKey {
  /// Creates a [StorageKey] with a [namespace] and a [name].
  const StorageKey({required this.namespace, required this.name});

  /// The feature or module that owns this key (e.g. `'auth'`, `'profile'`).
  final String namespace;

  /// The local identifier within the namespace (e.g. `'tokens'`, `'theme'`).
  final String name;

  /// The computed storage key string used by adapters: `'<namespace>_<name>'`.
  String get value => '${namespace}_$name';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is StorageKey &&
      namespace == other.namespace &&
      name == other.name;

  @override
  int get hashCode => Object.hash(namespace, name);

  @override
  String toString() => 'StorageKey($value)';
}
