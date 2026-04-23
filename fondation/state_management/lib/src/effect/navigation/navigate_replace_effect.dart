import 'package:state_management/src/bloc.dart';

/// Navigation effect to replace the current route with a new one
final class NavigateReplaceEffect extends NavigationEffect {
  /// Creates a [NavigateReplaceEffect] with the given parameters.
  NavigateReplaceEffect({
    required this.route,
    this.arguments,
  });

  /// The route to navigate to
  final String route;

  /// Optional arguments to pass to the route
  final Object? arguments;


  @override
  List<Object?> get props => [...super.props, route, arguments];
}
