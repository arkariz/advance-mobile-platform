import 'package:flutter/widgets.dart';
import 'package:state_management/src/bloc.dart';

/// Type definition for effect handlers
typedef EffectHandler<T extends UiEffect> = void Function(
  BuildContext context,
  T effect,
);

/// Maps effect types to handlers
class EffectRegistry {
  final Map<Type, EffectHandler<UiEffect>> _handlers = {};

  /// Register handler for effect type [T].
  ///
  /// Throws [StateError] in debug mode if a handler for [T] is already
  /// registered. Double-registration is always a programming error.
  void register<T extends UiEffect>(EffectHandler<T> handler) {
    assert(
      !_handlers.containsKey(T),
      'A handler for $T is already registered. '
      'registerEffectHandlers() must only be called once.',
    );
    _handlers[T] = (context, effect) => handler(context, effect as T);
  }

  /// Dispatch effect to registered handler
  void handle(BuildContext context, UiEffect effect) {
    final handler = _handlers[effect.runtimeType];
    if (handler == null) {
      throw UnregisteredEffectError(effect);
    }
    handler(context, effect);
  }
}

/// Thrown when no handler registered for effect type
class UnregisteredEffectError extends Error {
  /// Creates an [UnregisteredEffectError] for the given [effect].
  UnregisteredEffectError(this.effect);

  /// The effect that has no registered handler.
  final UiEffect effect;


  @override
  String toString() =>
    'No handler registered for ${effect.runtimeType}. '
    'Use registry.register<${effect.runtimeType}>(handler).';
}

/// Global effect registry (initialized once)
final globalEffectRegistry = EffectRegistry();
