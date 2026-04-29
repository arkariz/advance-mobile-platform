import 'package:api_network/api_network.dart';
import 'package:api_storage/api_storage.dart';
import 'package:app_example/core/storage/app_storage.dart';
import 'package:app_example/features/auth/data/data.dart';
import 'package:app_example/features/auth/domain/domain.dart';
import 'package:app_example/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:di/di.dart';
import 'package:dio_network/dio_network.dart';


final class AuthScope extends IsolatedScope {
  AuthScope({required super.parentContainer});


  @override
  void bridge(GetIt c) {
    c.registerSingleton<Dio>(parent<Dio>());
    c.registerSingleton<NetworkCallHandler>(parent<NetworkCallHandler>());
    // App-wide storage — bridged so repositories in this scope can access it.
    c.registerSingleton<AppStorage>(parent<AppStorage>());
    // Cache box — bridged for AuthStorage instantiation below.
    c.registerSingleton<KeyValueStorage>(
      parent<KeyValueStorage>(instanceName: 'cache_kv'),
      instanceName: 'cache_kv',
    );
  }

  @override
  void register(GetIt c) {
    // Feature-scoped cache storage. Lifetime = this scope.
    c.registerLazySingleton<AuthStorage>(
      () => AuthStorage(cacheStorage: c<KeyValueStorage>(instanceName: 'cache_kv')),
    );
    c.registerLazySingleton<AuthDatasource>(
      () => AuthDatasource(c<Dio>()),
    );
    c.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        dataSource: c<AuthDatasource>(),
        networkCallHandler: c<NetworkCallHandler>(),
        appStorage: c<AppStorage>(),
        authStorage: c<AuthStorage>(),
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
