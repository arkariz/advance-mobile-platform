import 'package:state_management/src/bloc.dart';

/// Typed navigation effect that replaces the top route on the stack.
///
/// Uses [Navigator.pushReplacement] semantics: the current route is removed
/// but prior history beneath it is preserved. Use when refreshing a screen
/// with updated input while keeping the ability to navigate back to routes
/// below it.
///
/// This class is intentionally agnostic of any navigation framework.
final class NavigateReplaceEffect extends NavigationEffect {
  /// Creates a [NavigateReplaceEffect] with the given [keyId] and [input].
  NavigateReplaceEffect({required this.keyId, required this.input});

  /// The namespaced string identifier of the target route (e.g. `'profile.view'`).
  final String keyId;

  /// The input data for the target screen.
  final Object input;

  @override
  List<Object?> get props => [...super.props, keyId];
}
