import 'package:state_management/src/bloc.dart';

/// Navigation effect to pop the current route with an optional result
final class NavigatePopEffect extends NavigationEffect {
  /// Creates a [NavigatePopEffect] with an optional result.
  NavigatePopEffect({this.result});
  
  /// Optional result to return to the previous route when popping
  final Object? result;

  @override
  List<Object?> get props => [...super.props, result];
}
