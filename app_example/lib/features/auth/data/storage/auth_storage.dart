import 'package:api_storage/api_storage.dart';
import 'package:app_example/features/auth/data/storage/auth_storage_keys.dart';
import 'package:app_example/features/auth/domain/domain.dart';

/// Auth-feature typed storage accessor.
///
/// Backed by the `cache_kv` [KeyValueStorage] box — non-sensitive, fast,
/// and independently clearable from the secure [AppStorage].
///
/// ## Lifetime
///
/// Scoped to [AuthScope]. Created when the auth feature initialises and
/// disposed when the scope is torn down.
///
/// ## vs [AppStorage]
///
/// | | [AppStorage] | [AuthStorage] |
/// |---|---|---|
/// | Backend | SecureStorage (encrypted) | `cache_kv` box (plain) |
/// | Lifetime | App | Auth feature scope |
/// | Clearable alone | No | Yes |
///
/// ## Usage example
///
/// ```dart
/// // Write after fetching user from API:
/// await authStorage.cachedUser.write(user);
///
/// // Read for optimistic UI:
/// final cached = await authStorage.cachedUser.read(); // User? — null if evicted
///
/// // Invalidate cache on sign-out:
/// await authStorage.cachedUser.remove();
/// ```
final class AuthStorage {
  /// Creates an [AuthStorage] backed by [cacheStorage] (`cache_kv` box).
  AuthStorage({required KeyValueStorage cacheStorage})
      : cachedUser = StoredValue.json(
          key: AuthStorageKeys.cachedUser,
          fromJson: User.fromJson,
          toJson: (u) => u.toJson(),
          storage: cacheStorage,
        );

  /// Locally cached [User].
  ///
  /// Written on successful sign-in, removed on sign-out or cache invalidation.
  /// Use for optimistic display — always verify against secure storage or
  /// the network for auth decisions.
  final StoredValue<User> cachedUser;
}
