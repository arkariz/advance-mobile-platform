import 'package:dependencies/dependencies.dart';
import 'package:state_management/src/bloc.dart';

/// Base state with optional effect
///
/// Override == and hashCode to include effect for bloc emission,
/// while keeping effect out of [props] for optimized rebuilds.
abstract class UiState<T> extends Equatable {
  /// Creates a [UiState] with an optional [effect].
  const UiState({this.effect});
  
  /// Optional one-shot effect to trigger UI actions
  final UiEffect? effect;

  /// Indicates if this state has an associated effect.
  bool get hasEffect => effect != null;

  /// Returns a copy of this state with the provided fields replaced.
  /// Child classes must override and include their own fields.
  T copyWith({UiEffect? effect});

  /// Returns a copy of this state with the given [effect].
  T withEffect(UiEffect? effect) => copyWith(effect: effect);

  /// Override equality to include effect for bloc state comparison.
  /// This ensures bloc emits state when effect changes, even if props are same.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UiState) return false;
    // First compare Equatable props, then compare effect
    return super == other && effect == other.effect;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, effect);

  @override
  bool? get stringify => true;
}
