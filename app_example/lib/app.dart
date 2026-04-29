import 'package:app_example/features/auth/di/auth_scope.dart';
import 'package:app_example/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:di/di.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:state_management/state_management.dart';

/// Root application widget.
///
/// Initialises feature scopes, sets the [AppBlocObserver], and wires
/// [MaterialApp.router] with the pre-built [GoRouter].
///
/// [AuthScope] is session-tied (outlives any single route) so it is
/// initialised manually here. Its container is exposed via [ScopeProvider]
/// so that route-level scopes deeper in the tree can read it with
/// [ScopeProvider.of].
class App extends StatelessWidget {
  App({required this.getIt, required this.router, super.key}) {
    Bloc.observer = AppBlocObserver();
    _authScope = AuthScope(parentContainer: getIt);
    _authScope.init();
  }

  final GetIt getIt;
  final GoRouter router;
  late final AuthScope _authScope;

  @override
  Widget build(BuildContext context) {
    return ScopeProvider(
      container: _authScope.container,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authScope.container.get<AuthBloc>()),
        ],
        child: MaterialApp.router(
          title: 'DI Architecture Demo',
          theme: ThemeData(colorSchemeSeed: Colors.indigo),
          routerConfig: router,
          builder: (context, child) {
            if (!kDebugMode) return child ?? const SizedBox.shrink();
            return Stack(
              children: [
                child ?? const SizedBox.shrink(),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'dev_menu',
                    backgroundColor: Colors.deepPurple,
                    onPressed: () => router.push('/dev-menu'),
                    child: const Icon(Icons.developer_mode, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
