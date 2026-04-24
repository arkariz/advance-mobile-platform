import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:navigation/navigation.dart';

/// GoRouter adapter for [RouteNode].
///
/// Converts a [RouteNode] into a [GoRoute] understood by GoRouter.
/// Lives in the app layer so [package:navigation] stays vendor-agnostic.
///
/// The route [path] is `'/<keyId>'` (e.g. `'/auth.login'`).
/// Input is passed via [GoRouterState.extra] as a [RouteInput]; falls back
/// to [EmptyInput] when no extra is provided (e.g. deep links).
extension RouteNodeGoRouterExt on RouteNode {
  /// Builds a [GoRoute] for this node.
  GoRoute toGoRoute() {
    return GoRoute(
      path: '/$keyId',
      name: keyId,
      pageBuilder: (context, state) {
        final RouteInput input;
        final extra = state.extra;
        if (extra is RouteInput) {
          input = extra;
        } else if (defaultInput != null) {
          input = defaultInput!;
        } else {
          throw StateError(
            'Route "$keyId" received no RouteInput (deep link or missing extra) '
            'and has no defaultInput factory. '
            'Provide defaultInput in RouteNode.typed() to support deep linking.',
          );
        }
        final child = buildWidget(context, input);

        return switch (transition) {
          RouteTransition.material => MaterialPage(child: child),
          RouteTransition.fadeIn => CustomTransitionPage(
              child: child,
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
            ),
          RouteTransition.slideFromRight => CustomTransitionPage(
              child: child,
              transitionsBuilder: (_, animation, __, child) => SlideTransition(
                position: Tween(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
          RouteTransition.slideFromBottom => CustomTransitionPage(
              child: child,
              transitionsBuilder: (_, animation, __, child) => SlideTransition(
                position: Tween(
                  begin: const Offset(0.0, 1.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
          RouteTransition.none => CustomTransitionPage(
              child: child,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              transitionsBuilder: (_, __, ___, child) => child,
            ),
        };
      },
    );
  }
}
