import 'package:app_example/features/auth/domain/domain.dart';

abstract interface class AuthRepository {
  Future<User> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
