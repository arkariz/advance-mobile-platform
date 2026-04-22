/// Framework package for dependency injection lifecycle governance.
/// Provides three orthogonal primitives:
/// - [DiBoot] — enforces the two-phase root container bootstrap protocol.
///    Callers must invoke [DiBoot.run] and await it before [runApp], and
///    [DiBoot.warmUp] after [runApp]. Out-of-order invocation is undefined.
/// - [IsolatedScope] — base class for all feature-level DI scopes. Each scope
///    owns an independent [GetIt] container. Consumers must call [IsolatedScope.init]
///    before accessing [IsolatedScope.container], and [IsolatedScope.dispose]
///    when the scope lifetime ends. Accessing the container outside this
///    window throws [StateError].
///  - [ScopeWidget] / [ScopeProvider] — Flutter lifecycle binding for
///    [IsolatedScope]. [ScopeWidget] is the ONLY sanctioned mechanism for
///    binding scope lifetime to a widget subtree. Manual scope creation in
///    [State.initState] is permitted only for session-tied scopes that outlive
///    a single route.
/// 
/// Ownership
/// This package is consumed by the application layer (`app_example`) and
/// by feature scope files. It MUST NOT depend on any feature package.
library;

export 'package:get_it/get_it.dart';
export 'package:injectable/injectable.dart';

export 'src/di_boot.dart';
export 'src/isolated_scope.dart';
export 'src/scope_provider.dart';
export 'src/scope_widget.dart';
