import 'package:app_example/analytics/analytics_service.dart';
import 'package:app_example/di/root_registrar.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

@InjectableInit(
  initializerName: r'$initAppGetIt',
  preferRelativeImports: true,
  asExtension: true,
  generateForDir: ['lib'],
)
// ignore: unused_element
void _appInjectableInit() {}


final class RootRegistrar {
  const RootRegistrar._();

  static Future<void> init(
    GetIt container, {
    String? environment,
  }) async {
    await container.$initAppGetIt(environment: environment);
    await container.allReady();
  }

  static List<void Function(GetIt)> warmUp() => [
    (container) => container<AnalyticsService>(),
  ];
}
