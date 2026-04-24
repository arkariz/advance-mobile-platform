import 'package:state_management/src/bloc.dart';

/// Navigation effect that navigates to the target screen, clearing the
/// entire back stack.
///
/// Equivalent to [GoRouter.go] / [Navigator.pushAndRemoveUntil]. Use when
/// the user should not be able to navigate back to the previous screen
/// (e.g., going from login to home after authentication).
///
/// This class is intentionally agnostic of any navigation framework.
/// It does not depend on [RouteKey] or [RouteInput] — those are resolved
/// by the handler layer (e.g., [RouteRegistry]) using [keyId] as a lookup key.
///
/// ## Example
/// ```dart
/// emit(state.withEffect(
///   NavigateGoEffect(
///     keyId: AuthRouteKeys.home.id,
///     input: const HomeInput(),
///   ),
/// ));
/// ```
final class NavigateGoEffect extends NavigationEffect {
  /// Creates a [NavigateGoEffect] with the given [keyId] and [input].
  NavigateGoEffect({required this.keyId, required this.input});

  /// The namespaced string identifier of the target route (e.g. `'auth.home'`).
  final String keyId;

  /// The input data for the target screen.
  ///
  /// The concrete type is known at the call site and resolved by the handler.
  final Object input;

  @override
  List<Object?> get props => [...super.props, keyId];
}
