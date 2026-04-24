import 'package:flutter/widgets.dart';
import 'package:navigation/src/route_input.dart';
import 'package:navigation/src/route_key.dart';
import 'package:navigation/src/route_transition.dart';

/// Describes a single navigable screen: its key, how to build its widget,
/// and which transition to use when entering it.
///
/// [RouteNode] is deliberately not generic at the class level. Type safety is
/// enforced at construction time via [RouteNode.typed], which ensures the
/// [RouteKey]'s input type matches the builder's input type. Internally the
/// builder is stored with a type-erased signature so nodes can be held in
/// plain [List<RouteNode>] collections without variance issues.
///
/// ## Usage
/// ```dart
/// RouteNode.typed<LoginInput>(
///   key: AuthRouteKeys.login,
///   builder: (context, input) => LoginPage(input: input),
///   transition: RouteTransition.fadeIn,
/// )
/// ```
final class RouteNode {
  const RouteNode._({
    required this.keyId,
    required Widget Function(BuildContext, RouteInput) builder,
    required this.transition,
    RouteInput Function()? defaultInput,
  })  : _builder = builder,
        _defaultInput = defaultInput;

  /// The string identifier of the [RouteKey] this node is registered under.
  final String keyId;

  /// The transition animation used when navigating to this route.
  final RouteTransition transition;

  final Widget Function(BuildContext, RouteInput) _builder;

  /// Optional factory that produces a [RouteInput] when none is provided,
  /// e.g. when the screen is opened via a deep link without `extra`.
  ///
  /// If `null` and no `extra` is present, the handler will throw a
  /// [StateError] with a clear message instead of an obscure [TypeError].
  final RouteInput Function()? _defaultInput;

  /// Produces the default [RouteInput] for this node, or `null` if none
  /// was registered.
  RouteInput? get defaultInput => _defaultInput?.call();

  /// Creates a [RouteNode] with compile-time input type validation.
  ///
  /// [TInput] is inferred from [key] — no explicit type argument is needed
  /// when the key is a properly typed [RouteKey].
  ///
  /// Provide [defaultInput] to support opening this screen via a deep link
  /// (i.e., when no [RouteInput] is available in [GoRouterState.extra]).
  static RouteNode typed<TInput extends RouteInput>({
    required RouteKey<TInput> key,
    required Widget Function(BuildContext context, TInput input) builder,
    RouteTransition transition = RouteTransition.material,
    TInput Function()? defaultInput,
  }) {
    return RouteNode._(
      keyId: key.id,
      builder: (ctx, input) => builder(ctx, input as TInput),
      transition: transition,
      defaultInput: defaultInput,
    );
  }

  /// Builds the destination widget for this route.
  Widget buildWidget(BuildContext context, RouteInput input) =>
      _builder(context, input);
}
