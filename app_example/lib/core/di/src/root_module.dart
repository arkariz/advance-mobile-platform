import 'package:api_network/api_network.dart';
import 'package:api_storage/api_storage.dart';
import 'package:app_example/core/storage/app_storage.dart';
import 'package:di/di.dart';
import 'package:dio_network/dio_network.dart';
import 'package:hive_storage/hive_storage.dart';

@module
abstract class RootModule {
  // ── Lazy synchronous ──────────────────────────────────────────────
  @lazySingleton
  Dio dio() => DioBuilder('http://10.0.2.2:9011')
    .setTimeouts(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
    )
    .build();
  
  @lazySingleton
  NetworkCallHandler authNetworkCallHandler() => DioRestHandler();

  // ── Async pre-resolved ────────────────────────────────────────────
  @singleton
  @preResolve
  Future<bool> sharedPreferences() => Future.value(true);

  // ── Storage ──────────────────────────────────────────────────────
  //
  // Multiple KeyValueStorage boxes are registered with @Named so GetIt can
  // distinguish them. Inject with @Named('box_name') at the call site.
  //
  // Both HiveKeyValueStorage and HiveSecureStorage call
  // HiveStorageInitializer.init() internally, so the order here is safe.

  @singleton
  @preResolve
  @Named('app_kv')
  Future<KeyValueStorage> appKvStorage() async {
    return HiveKeyValueStorage.initialize(boxName: 'app_kv');
  }

  /// Example second box — e.g. for feature-level cache that can be cleared
  /// independently from primary app state.
  @singleton
  @preResolve
  @Named('cache_kv')
  Future<KeyValueStorage> cacheKvStorage() async {
    return HiveKeyValueStorage.initialize(boxName: 'cache_kv');
  }

  @singleton
  @preResolve
  Future<SecureStorage> secureStorage() => HiveSecureStorage.initialize();

  // Resolves after all @preResolve singletons above are ready.
  @singleton
  @preResolve
  Future<AppStorage> appStorage(SecureStorage secureStorage) async => AppStorage(secureStorage: secureStorage);
}
