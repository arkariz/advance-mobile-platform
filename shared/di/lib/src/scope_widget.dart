import 'dart:async';

import 'package:di/src/isolated_scope.dart';
import 'package:di/src/scope_provider.dart';
import 'package:flutter/widgets.dart';

/// Binds an [IsolatedScope] lifetime to a widget subtree.
///
/// [ScopeWidget] is the canonical mechanism for route-tied or screen-tied
/// scopes. It calls [IsolatedScope.init] in [State.initState], wraps the
/// built subtree in a [ScopeProvider], and calls [IsolatedScope.dispose]
/// in [State.dispose].
///
/// ## Guarantees
/// - [builder] is only called after [IsolatedScope.init] has completed
///   successfully. The container exposed via [ScopeProvider.of] is fully
///   initialised when [builder] runs.
/// - [IsolatedScope.dispose] is called exactly once when the widget leaves
///   the tree, regardless of how the route is dismissed.
/// - [onInitializing] is shown for the entire duration of [IsolatedScope.init].
///   It is replaced by [builder] atomically after init completes.
///
/// ## Constraints
/// - [create] MUST construct a new [IsolatedScope] instance and MUST NOT
///   call [IsolatedScope.init] on it. [ScopeWidget] owns initialisation.
/// - [create] is called exactly once per [ScopeWidget] instance.
///   Returning a shared or pre-initialised scope from [create] is a
///   programming error.
/// - [ScopeWidget] MUST be used for route-tied scopes. Session-tied scopes
///   that outlive a single route MAY be managed manually in [State].
///
/// ## Failure Behavior
/// - If [IsolatedScope.init] throws, the exception is not caught by
///   [ScopeWidget]. The widget remains in the initialising state and the
///   exception propagates up the [Future] chain. The owning [State] never
///   transitions to built, and [IsolatedScope.dispose] is still called in
///   [State.dispose] to release any partially-committed registrations.
///
/// ## Concurrency
/// Init runs as a [Future] on the UI event loop. [builder] is called on
/// the UI thread after [setState] triggers a rebuild. No additional
/// concurrency guarantees are provided.
///
/// ## Integration
/// [ScopeWidget] inserts [ScopeProvider] automatically. Any widget in the
/// [builder] subtree may call [ScopeProvider.of] to access the container.
/// Passing the scope as a constructor argument to child widgets is an
/// anti-pattern — use [ScopeProvider.of] instead.
///
/// ## Anti-pattern
/// - Do NOT nest [ScopeWidget]s where the inner scope's [create] calls
///   [ScopeProvider.of] at construction time. [ScopeProvider] is not yet
///   inserted when [create] is called. Retrieve the parent container
///   before calling [ScopeWidget] and pass it via closure.
/// - Do NOT re-use a single [IsolatedScope] instance across multiple
///   [ScopeWidget] instances. Scope instances are not sharable.
class ScopeWidget<S extends IsolatedScope> extends StatefulWidget {
  /// Creates a new [ScopeWidget] with the given scope factory, builder, and optional initializing widget.
  ///
  /// [create] is the critical parameter: it is called once during [State.initState] to construct the scope instance.
  /// It MUST return a new, uninitialised scope.
  /// 
  /// [builder] is called after the scope is fully initialised to build the widget subtree.
  /// The subtree is automatically wrapped in a [ScopeProvider] that exposes the scope container.
  /// 
  /// [onInitializing] is an optional widget shown while the scope is initializing.
  /// It MUST NOT attempt to access the scope container, as it is not yet available.
  /// If not provided, a [SizedBox.shrink] is shown by default.
  const ScopeWidget({
    required this.create,
    required this.builder,
    this.onInitializing,
    super.key,
  });

  /// Constructs the [IsolatedScope] instance.
  ///
  /// ## Constraints
  /// Called once during [State.initState]. MUST NOT call [IsolatedScope.init].
  final S Function() create;

  /// Builds the widget subtree after [IsolatedScope.init] completes.
  ///
  /// ## Constraints
  /// The subtree is automatically wrapped in [ScopeProvider]. MUST NOT
  /// receive the scope as a constructor parameter — use [ScopeProvider.of]
  /// within the subtree.
  final Widget Function(BuildContext context, S scope) builder;

  /// Widget shown while [IsolatedScope.init] is in progress.
  ///
  /// Defaults to [SizedBox.shrink] if not provided. MUST NOT attempt to
  /// access the scope container — it is not yet initialised.
  final WidgetBuilder? onInitializing;

  @override
  State<ScopeWidget<S>> createState() => _ScopeWidgetState<S>();
}

class _ScopeWidgetState<S extends IsolatedScope> extends State<ScopeWidget<S>> {
  late final S _scope;
  bool _initialised = false;

  @override
  void initState() {
    super.initState();
    _scope = widget.create();
    unawaited(_init());
  }

  Future<void> _init() async {
    await _scope.init();
    if (mounted) setState(() => _initialised = true);
  }

  @override
  void dispose() {
    // dispose() must be synchronous; fire the async cleanup without awaiting.
    unawaited(_scope.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialised) {
      return widget.onInitializing?.call(context) ?? const SizedBox.shrink();
    }
    return ScopeProvider(
      container: _scope.container,
      child: widget.builder(context, _scope),
    );
  }
}
