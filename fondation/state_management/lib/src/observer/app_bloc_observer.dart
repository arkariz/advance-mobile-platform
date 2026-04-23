import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:state_management/src/bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Global BLoC observer for debugging and analytics.
///
/// Accepts an optional [Talker] instance for structured logging.
/// If none is provided, a default [Talker] instance is created.
///
/// Usage:
/// ```dart
/// Bloc.observer = AppBlocObserver(talker: myTalker);
/// ```
class AppBlocObserver extends BlocObserver {
  /// Creates an [AppBlocObserver] with an optional [Talker] for logging.
  AppBlocObserver({Talker? talker}) : _talker = talker ?? Talker();

  final Talker _talker;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    _talker.verbose('🟢 onCreate: ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _talker.info(
      '📩 onEvent: ${bloc.runtimeType} ← ${event.runtimeType}\n'
      '  $event',
    );
  }

  /// Called for both [Bloc] and [Cubit] on every state change.
  ///
  /// Highlights when the next state carries a [UiEffect].
  /// Note: [onTransition] is intentionally omitted to avoid duplicate logs
  /// for [Bloc], since [onChange] already captures the same state change.
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);

    final nextState = change.nextState;
    final uiState = nextState is UiState ? nextState : null;
    final hasEffect = uiState?.hasEffect ?? false;

    final label = hasEffect
        ? '🔄✨ onChange (effect: ${uiState!.effect.runtimeType})'
        : '🔄 onChange';

    _talker.info('$label: ${bloc.runtimeType}\n  ${change.currentState} → $nextState');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _talker.handle(error, stackTrace, '❌ onError: ${bloc.runtimeType}');
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    _talker.verbose('🔴 onClose: ${bloc.runtimeType}');
  }
}
