import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

/// An [InheritedWidget] that makes a scope-local [GetIt] container available
/// to a widget subtree without requiring explicit parameter passing.
///
/// ## Guarantees
/// - The [container] exposed by [of] and [maybeOf] is stable for the lifetime
///   of the [ScopeWidget] above it. Widget rebuilds do NOT change the container
///   identity; [updateShouldNotify] returns `false` in the steady state.
/// - [of] always returns a fully-initialised container: [ScopeWidget] inserts
///   [ScopeProvider] only after [IsolatedScope.init] completes.
///
/// ## Constraints
/// - MUST NOT be instantiated directly by application code.
///   The canonical insertion point is [ScopeWidget], which guarantees that
///   the container is fully initialised before this widget is inserted.
/// - [of] MUST only be called from within a widget subtree that is a
///   descendant of a [ScopeWidget] or manually constructed [ScopeProvider].
///   Calling it outside that subtree throws [StateError].
///
/// ## Failure Behavior
/// - [of] throws [StateError] if no [ScopeProvider] ancestor exists in the
///   widget tree. This is a programming error; use [maybeOf] when presence
///   is conditional.
///
/// ## Concurrency
/// All access is on the Flutter UI thread. No concurrency guarantees are needed.
///
/// ## Anti-pattern
/// Do NOT store the result of [of] in a field outside of a `build` method.
/// Container identity is stable, but holding a reference beyond the widget
/// lifecycle prevents the scope from being garbage-collected after disposal.
class ScopeProvider extends InheritedWidget {
  /// Creates a new [ScopeProvider] with the given [container] and child widget.
  const ScopeProvider({
    required this.container,
    required super.child,
    super.key,
  });

  /// The scope-local [GetIt] container for this scope.
  final GetIt container;

  /// Returns the [GetIt] container from the nearest [ScopeProvider] ancestor.
  ///
  /// ## Failure Behavior
  /// Throws [StateError] if no [ScopeProvider] exists in the widget tree.
  /// Use [maybeOf] when the presence of a [ScopeProvider] is not guaranteed.
  static GetIt of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ScopeProvider>();
    if (provider == null) {
      throw StateError(
        'ScopeProvider.of called with a context that does not contain a '
        'ScopeProvider. Wrap the subtree with ScopeWidget or ScopeProvider.',
      );
    }
    return provider.container;
  }

  /// Returns the [GetIt] container from the nearest [ScopeProvider] ancestor,
  /// or `null` if no ancestor exists.
  static GetIt? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ScopeProvider>()?.container;

  @override
  bool updateShouldNotify(ScopeProvider oldWidget) => container != oldWidget.container;
}
