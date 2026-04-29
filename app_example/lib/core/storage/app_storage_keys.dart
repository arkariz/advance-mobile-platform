import 'package:api_storage/api_storage.dart';

/// Centralized [StorageKey] constants for app-wide persisted values.
///
/// Keys in this file span the full app lifecycle and are not owned by any
/// single feature. Feature-specific keys live alongside their feature in
/// `features/<name>/data/storage/`.
abstract final class AppStorageKeys {
  /// The currently authenticated [User].
  ///
  /// Written on sign-in, removed on sign-out.
  static const currentUser = StorageKey(namespace: 'app', name: 'current_user');
}
