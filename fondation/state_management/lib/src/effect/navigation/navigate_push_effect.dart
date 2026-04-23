import 'package:state_management/src/bloc.dart';

/// Navigation effect to push a new route with optional arguments
final class NavigatePushEffect extends NavigationEffect {
  /// Creates a [NavigatePushEffect] with the given parameters.
  NavigatePushEffect({
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
