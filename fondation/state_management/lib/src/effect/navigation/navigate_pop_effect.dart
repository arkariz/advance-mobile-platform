import 'package:state_management/src/bloc.dart';

/// Navigation effect that pops the current route.
///
/// Equivalent to [Navigator.pop]. Carries an optional [result] that is
/// returned to the caller that pushed this screen (e.g., via
/// [NavigatePushEffect.onResult]).
///
/// ## Example
/// ```dart
/// // In the pushed screen's BLoC:
/// emit(state.withEffect(NavigatePopEffect(result: selectedAddress)));
/// ```
final class NavigatePopEffect extends NavigationEffect {
  /// Creates a [NavigatePopEffect] with an optional [result].
  NavigatePopEffect({this.result});

  /// Optional value to pass back to the screen that pushed this one.
  final Object? result;

  @override
  List<Object?> get props => [...super.props, result];
}
