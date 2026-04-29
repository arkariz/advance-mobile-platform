import 'package:api_storage/api_storage.dart';
import 'package:app_example/core/storage/app_storage_keys.dart';
import 'package:app_example/features/auth/domain/domain.dart';

/// App-wide typed storage accessor.
///
/// Owns every [StoredValue] whose lifetime matches the app lifecycle — data
/// that must survive across feature navigations, restarts, and cold-starts.
///
/// Backed by [SecureStorage] (AES-encrypted on device) so sensitive fields
/// like the authenticated user are never written to plain files.
///
/// ## Registration
///
/// Registered as a synchronous `@singleton` in [RootModule] after
/// [SecureStorage] is pre-resolved. Inject it wherever cross-feature state
/// is needed — bridge it into isolated scopes via `parent<AppStorage>()`.
///
/// ## Usage example
///
/// ```dart
/// // Write on sign-in:
/// await appStorage.currentUser.write(user);
///
/// // Read at app start:
/// final user = await appStorage.currentUser.read(); // User? — null if signed out
///
/// // Clear on sign-out:
/// await appStorage.currentUser.remove();
/// ```
final class AppStorage {
  /// Creates an [AppStorage] backed by [secureStorage].
  AppStorage({required SecureStorage secureStorage})
      : currentUser = StoredValue.json(
          key: AppStorageKeys.currentUser,
          fromJson: User.fromJson,
          toJson: (u) => u.toJson(),
          storage: secureStorage,
        );

  /// The currently authenticated user.
  ///
  /// `null` when no user is signed in.
  final StoredValue<User> currentUser;
}
