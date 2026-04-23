import 'package:state_management/src/bloc.dart';

/// Navigation effect to go to a route with optional arguments and query parameters
final class NavigateGoEffect extends NavigationEffect {
  /// Creates a [NavigateGoEffect] with the given parameters.
  NavigateGoEffect({
    required this.route,
    this.arguments,
    this.queryParameters,
  });

  /// Creates a [NavigateGoEffect] with the given parameters.
  final String route;

  /// Optional arguments to pass to the route
  final Object? arguments;

  /// Optional query parameters to include in the route
  final Map<String, String>? queryParameters;

  @override
  List<Object?> get props => [...super.props, route, arguments, queryParameters];
}
