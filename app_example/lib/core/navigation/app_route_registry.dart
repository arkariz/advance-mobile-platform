import 'package:app_example/features/auth/navigation/auth_route_keys.dart';
import 'package:app_example/features/auth/navigation/auth_route_module.dart';
import 'package:app_example/core/navigation/route_node_go_router_ext.dart';
import 'package:app_example/features/home/navigation/home_route_module.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';

final router = AppRouteRegistry.buildAppRouter();

abstract final class AppRouteRegistry {
  static final _modules = <FeatureRouteModule>[
    const AuthRouteModule(),
    const HomeRouteModule(),
    // Add further feature modules here:
  ];

  // Built once — reused by both GoRouter and DevMenuScreen.
  static final _registry = RouteRegistry.fromModules(_modules);

  static List<GoRoute> _buildGoRoutes() => _registry.registeredNodes
    .map((node) => node.toGoRoute())
    .toList();

  static GoRouter buildAppRouter() {
    late final GoRouter router;

    router = GoRouter(
      initialLocation: '/${AuthRouteKeys.login.id}',
      debugLogDiagnostics: kDebugMode,
      routes: [
        ..._buildGoRoutes(),
        if (kDebugMode)
          GoRoute(
            path: '/dev-menu',
            pageBuilder: (ctx, _) => NoTransitionPage(
              child: DevMenuScreen(
                registry: _registry,
                onEntryTap: (entry) {
                  router.pop();
                  router.push('/${entry.keyId}', extra: entry.createInput());
                },
              ),
            ),
          ),
      ],
    );

    return router;
  }
}
