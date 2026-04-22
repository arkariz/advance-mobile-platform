import 'package:api_network/api_network.dart';
import 'package:di/di.dart';
import 'package:dio_network/dio_network.dart';
import 'package:get_it/get_it.dart';

import '../api/auth_repository.dart';
import '../impl/auth_repository_impl.dart';
import '../impl/datasource/auth_datasource.dart';


final class AuthScope extends IsolatedScope {
  AuthScope({required super.parentContainer});


  @override
  void bridge(GetIt c) {
    c.registerSingleton<Dio>(parent<Dio>());
    c.registerSingleton<NetworkCallHandler>(parent<NetworkCallHandler>(),);
  }

  @override
  void register(GetIt c) {
    c.registerLazySingleton<AuthDatasource>(
      () => AuthDatasource(c<Dio>()),
    );
    c.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        dataSource: c<AuthDatasource>(),
        networkCallHandler: c<NetworkCallHandler>(),
      ),
      dispose: (r) => (r as AuthRepositoryImpl).dispose(),
    );
  }
}
