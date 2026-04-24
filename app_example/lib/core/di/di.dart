import 'package:app_example/core/di/src/app_injectable.config.dart';
import 'package:di/di.dart';

final di = DiBoot(
  init: (c) => _RootRegistrar.init(c),
  warmups: _RootRegistrar.warmUp(),
);

final class _RootRegistrar {
  const _RootRegistrar._();

  static Future<void> init(
    GetIt container, {
    String? environment,
  }) async {
    await container.$appInjectableInit(environment: environment);
    await container.allReady();
  }

  static List<void Function(GetIt)> warmUp() => [
    // Example warmup: pre-instantiate analytics service to start tracking app open event immediately.
    // (container) => container<AnalyticsService>(),
  ];
}
