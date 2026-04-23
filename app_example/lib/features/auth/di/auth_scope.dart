import 'package:api_network/api_network.dart';
import 'package:app_example/features/auth/api/auth_repository.dart';
import 'package:app_example/features/auth/impl/auth_repository_impl.dart';
import 'package:app_example/features/auth/impl/datasource/auth_datasource.dart';
import 'package:app_example/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:di/di.dart';
import 'package:dio_network/dio_network.dart';


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
    c.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      authRepository: c<AuthRepository>(),
    ),
    dispose: (b) => b.close(),
  );
  }
}
