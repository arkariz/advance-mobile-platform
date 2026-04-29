import 'dart:async';
import 'package:app_example/core/storage/app_storage.dart';
import 'package:app_example/features/auth/data/data.dart';
import 'package:app_example/features/auth/domain/domain.dart';
import 'package:injectable/injectable.dart';
import 'package:api_network/api_network.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthDatasource dataSource,
    required NetworkCallHandler networkCallHandler,
    required AppStorage appStorage,
    required AuthStorage authStorage,
  })  : _dataSource = dataSource,
        _handler = networkCallHandler,
        _appStorage = appStorage,
        _authStorage = authStorage;

  final AuthDatasource _dataSource;
  final NetworkCallHandler _handler;
  final AppStorage _appStorage;
  final AuthStorage _authStorage;

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    return _handler.handle(() async {
      final result = await _dataSource.signIn(email: email, password: password);
      final user = User(
        email: result.data?.email ?? '',
        id: result.data?.id ?? '',
        name: result.data?.name ?? '',
      );
      // Persist the authenticated user: secure storage (app-wide) + cache box.
      await Future.wait([
        _appStorage.currentUser.write(user),
        _authStorage.cachedUser.write(user),
      ]);
      return user;
    });
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(seconds: 2));
    // Clear both storages on sign-out.
    await Future.wait([
      _appStorage.currentUser.remove(),
      _authStorage.cachedUser.remove(),
    ]);
  }

  @override
  Future<User?> getSignedInUser() => _appStorage.currentUser.read();

  @override
  Future<User?> getCachedUser() => _authStorage.cachedUser.read();

  @disposeMethod
  void dispose() {
    // _authStateSubject.close();
  }
}
