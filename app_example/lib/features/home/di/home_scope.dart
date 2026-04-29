import 'package:app_example/features/auth/domain/domain.dart';
import 'package:app_example/features/home/presentation/bloc/home_bloc.dart';
import 'package:di/di.dart';

/// Feature-level DI scope for the Home feature.
///
/// Lifetime: bound to the Home route via [ScopeWidget]. Created when the
/// Home route enters the tree and disposed when it leaves (after any
/// exit animation completes).
final class HomeScope extends IsolatedScope {
  HomeScope({required super.parentContainer});

  @override
  void bridge(GetIt c) {
    // AuthRepository lives in AuthScope; bridge it so HomeBloc can call signOut.
    c.registerSingleton<AuthRepository>(parent<AuthRepository>());
  }

  @override
  void register(GetIt c) {
    c.registerLazySingleton<HomeBloc>(
      () => HomeBloc(authRepository: c<AuthRepository>()),
      dispose: (b) => b.close(),
    );
  }
}
