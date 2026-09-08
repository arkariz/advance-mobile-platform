import 'package:flutter/widgets.dart';
import 'package:state_management/src/bloc.dart';

/// Effect that executes a callback function when handled. This is useful for
/// general purposes where you want to perform an action in response to an event, without needing to define a specific effect class for that action.
final class CallbackEffect extends UiEffect {
  /// Creates a [CallbackEffect] with the given [callback].
  /// The [callback] is a function that will be executed when the effect is handled.
  CallbackEffect({
    required this.callback,
  });

  /// Callback function to be executed when the effect is handled
  final void Function(BuildContext) callback;

  @override
  List<Object?> get props => [...super.props, callback];
}
