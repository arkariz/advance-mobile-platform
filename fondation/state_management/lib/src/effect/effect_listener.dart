import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:state_management/src/bloc.dart';

/// Listens to state changes and dispatches effects to handlers
class EffectListener<B extends BlocBase<S>, S extends UiState<S>> extends StatelessWidget {
  /// Creates an [EffectListener] that listens to the specified [Bloc] and handles effects using the provided [EffectRegistry].
  const EffectListener({
    required this.child,
    this.registry,
    super.key,
  });

  /// The child widget to render.
  final Widget child;
  /// Optional registry to handle effects. If not provided, the global registry will be used.
  final EffectRegistry? registry;


  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      listenWhen: (prev, curr) => curr.hasEffect && prev.effect != curr.effect,
      listener: (context, state) {
        final effect = state.effect;
        if (effect == null) return;

        (registry ?? globalEffectRegistry).handle(context, effect);
      },
      child: child,
    );
  }
}
