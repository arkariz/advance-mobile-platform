import 'package:app_example/di/root_registrar.dart';
import 'package:app_example/features/auth/di/auth_scope.dart';
import 'package:app_example/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app_example/features/auth/presentation/pages/login_page.dart';
import 'package:di/di.dart';
import 'package:flutter/material.dart';
import 'package:state_management/state_management.dart';

final GetIt rootGetIt = GetIt.instance;

final _boot = DiBoot(
  init: (c) => RootRegistrar.init(c, environment: 'prod'),
  warmups: RootRegistrar.warmUp(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint('[DI] Phase 1 — blocking init...');
  await _boot.run(rootGetIt);
  debugPrint('[DI] Phase 1 complete — all blocking deps ready. Starting app...');

  runApp(App(getIt: rootGetIt));

  // Phase 2: fire-and-forget warmups start here, after the first frame.
  _boot.warmUp(rootGetIt);
}

// ─────────────────────────────────────────────────────────────────────────────
// App widget — receives the fully initialised root container.
// ─────────────────────────────────────────────────────────────────────────────
class App extends StatelessWidget {
  App({required this.getIt, super.key}) {
    Bloc.observer = AppBlocObserver();
    _authScope = AuthScope(parentContainer: getIt);
    _authScope.init();
  }

  final GetIt getIt;
  late final AuthScope _authScope;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authScope.container.get<AuthBloc>()),
      ],
      child: MaterialApp(
        title: 'DI Architecture Demo',
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: LoginPage(),
      ),
    );
  }
}