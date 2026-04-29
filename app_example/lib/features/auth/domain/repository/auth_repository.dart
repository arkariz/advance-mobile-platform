import 'package:app_example/features/auth/domain/domain.dart';

abstract interface class AuthRepository {
  Future<User> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  /// Returns the authenticated [User] from secure storage.
  ///
  /// Returns `null` when no user is signed in. Use this to restore session
  /// state on cold start — it reads from encrypted storage, so it is
  /// authoritative for auth decisions.
  Future<User?> getSignedInUser();

  /// Returns the locally cached [User] from the fast cache box.
  ///
  /// Returns `null` when the cache is empty or has been invalidated.
  /// Use for optimistic UI only — never for auth gating.
  Future<User?> getCachedUser();
}
