import 'package:api_storage/api_storage.dart';

/// [StorageKey] constants owned by the auth feature.
///
/// These keys use the `cache_kv` box — data here can be cleared independently
/// from the secure app state (e.g. on cache invalidation) without affecting
/// [AppStorageKeys.currentUser] in secure storage.
abstract final class AuthStorageKeys {
  /// Cached [User] for fast reads without hitting the network.
  static const cachedUser = StorageKey(namespace: 'auth', name: 'cached_user');
}
