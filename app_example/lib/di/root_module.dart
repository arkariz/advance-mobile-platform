import 'package:dio_network/dio_network.dart';
import 'package:api_network/api_network.dart';
import 'package:di/di.dart';

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
}
