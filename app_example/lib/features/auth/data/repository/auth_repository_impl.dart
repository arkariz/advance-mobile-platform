import 'dart:async';
import 'package:app_example/features/auth/data/data.dart';
import 'package:app_example/features/auth/domain/domain.dart';
import 'package:injectable/injectable.dart';
import 'package:api_network/api_network.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthDatasource dataSource,
    required NetworkCallHandler networkCallHandler
  }): _dataSource = dataSource,
      _handler = networkCallHandler;

  final AuthDatasource _dataSource;
  final NetworkCallHandler _handler;

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    return _handler.handle(() async {
      final result = await _dataSource.signIn(email: email, password: password);
      return User(
        email: result.data?.email ?? '',
        id: result.data?.id ?? '',
        name: result.data?.name ?? '',
      );
    });
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(seconds: 2));
  }

  @disposeMethod
  void dispose() {
    // _authStateSubject.close();
  }
}
