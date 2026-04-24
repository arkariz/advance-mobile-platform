import 'package:state_management/src/bloc.dart';

/// Typed navigation effect that pushes the target screen onto the stack.
///
/// Equivalent to [Navigator.push]. Supports an optional [onResult] callback
/// so the originating BLoC can react to a result without awaiting a [Future].
///
/// This class is intentionally agnostic of any navigation framework.
/// It does not depend on [RouteKey] or [RouteInput].
///
/// ## Result-passing pattern
/// The effect handler awaits the push and calls [onResult] with the returned
/// value. The BLoC's [onResult] callback dispatches a new event back into the
/// BLoC, keeping it pure (no async awaiting inside event handlers).
///
/// ```dart
/// emit(state.withEffect(
///   NavigatePushEffect.withResult<Address>(
///     keyId: ProfileRouteKeys.addressPicker.id,
///     input: AddressInput(preselected: current),
///     onResult: (address) {
///       if (address != null) add(AddressSelected(address));
///     },
///   ),
/// ));
/// ```
final class NavigatePushEffect extends NavigationEffect {
  /// Creates a [NavigatePushEffect] without a result callback.
  NavigatePushEffect({required this.keyId, required this.input})
      : onResult = null;

  NavigatePushEffect._withResult({
    required this.keyId,
    required this.input,
    required this.onResult,
  });

  /// Creates a [NavigatePushEffect] with a typed result callback.
  ///
  /// [onResult] is wrapped in a type-erasing closure so it can be stored
  /// without a generic parameter. The cast inside the closure is safe because
  /// the handler always passes back the value returned by the pushed screen,
  /// which must be of type [TResult].
  static NavigatePushEffect withResult<TResult>({
    required String keyId,
    required Object input,
    required void Function(TResult? result) onResult,
  }) =>
      NavigatePushEffect._withResult(
        keyId: keyId,
        input: input,
        onResult: (r) => onResult(r as TResult?),
      );

  /// The namespaced string identifier of the target route (e.g. `'profile.addressPicker'`).
  final String keyId;

  /// The input data for the target screen.
  final Object input;

  /// Called by the effect handler after the pushed screen is popped.
  ///
  /// The argument is the value passed to [Navigator.pop], cast to the
  /// originally declared [TResult] type. May be `null` if the screen was
  /// popped without a result.
  final void Function(Object? result)? onResult;

  @override
  List<Object?> get props => [...super.props, keyId];
}
