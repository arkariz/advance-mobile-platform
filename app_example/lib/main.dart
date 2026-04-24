import 'package:app_example/app.dart';
import 'package:app_example/core/effect_handler/app_effect_registry.dart';
import 'package:app_example/core/di/di.dart';
import 'package:app_example/core/navigation/app_route_registry.dart';
import 'package:di/di.dart';
import 'package:flutter/widgets.dart';

final GetIt rootGetIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.run(rootGetIt);

  registerEffectHandlers(router: router);
  runApp(App(
    getIt: rootGetIt,
    router: router,
  ));

  // Phase 2: fire-and-forget warmups start here, after the first frame.
  di.warmUp(rootGetIt);
}