# di

Framework package for dependency injection lifecycle governance in a Flutter monorepo.

---

## Overview

`di` provides three orthogonal primitives. Each primitive has a single, well-defined responsibility. They do not overlap.

| Primitive | Responsibility |
|---|---|
| `DiBoot` | Enforce the two-phase root container bootstrap protocol |
| `IsolatedScope` | Base class for feature-level scopes with independently isolated `GetIt` containers |
| `ScopeWidget` / `ScopeProvider` | Bind an `IsolatedScope` lifetime to a Flutter widget subtree |

## Ownership

This package is owned by the platform team.

### Constraints

- MUST NOT depend on any feature package (`auth_api`, `transfer_api`, etc.).
- MUST NOT contain any application-layer registrations or business logic.
- Feature packages MUST NOT add registrations directly to this package.
- The application layer (`app_example`) MUST depend on `di` via `path:` dependency, not pub.dev.

---

## DiBoot

Enforces strict two-phase bootstrap: blocking init before `runApp`, fire-and-forget warmup after `runApp`.

```dart
final _boot = DiBoot(
  init: (container) => RootRegistrar.init(container),
  warmups: [
    (container) => container<AnalyticsService>(),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _boot.run(rootGetIt);   // phase 1 — must be awaited before runApp
  runApp(App(getIt: rootGetIt));
  _boot.warmUp(rootGetIt);      // phase 2 — must be called after runApp
}
```

### Guarantees

- After `run` returns, all `@preResolve` and async-singleton registrations are fully resolved and synchronously accessible via the container.
- `warmUp` tasks execute in independent `Future` microtasks and never block `runApp` or the first frame.
- Warmup exceptions are swallowed. A failing warmup does not affect other warmups or the app lifecycle.

### Constraints

- `run` MUST be awaited to completion before `runApp` is called.
- `warmUp` MUST be called after `runApp`, not before.
- Both methods MUST receive the same container instance. Passing different containers is a programming error.
- `run` and `warmUp` are NOT idempotent. Calling `run` twice on an already-initialised container causes duplicate registrations.
- Warmup callbacks MUST only trigger lazy construction (e.g. `container<MyService>()`). Computation on the resolved instance belongs in the instance's own initialiser.

### Failure Behavior

- If the `init` callback throws, the exception propagates from `run` unchanged. The container is partially initialised. The application MUST NOT call `runApp` and MUST treat this as a fatal startup error.
- If a warmup callback throws, the exception is silently swallowed. There is no error surface.

### Anti-pattern

```dart
// WRONG — warmUp before runApp exposes tasks to a partially-initialised container
await _boot.run(rootGetIt);
_boot.warmUp(rootGetIt); // ← must come AFTER runApp
runApp(...);
```

---

## IsolatedScope

Base class for feature-level DI scopes. Each scope allocates a fresh `GetIt.asNewInstance()` that shares **no** registrations with the parent container unless explicitly forwarded via `bridge`.

```dart
final class TransferScope extends IsolatedScope {
  TransferScope({required super.parentContainer});

  @override
  void bridge(GetIt parent, GetIt container) {
    // Whitelist exactly the deps this scope needs from the parent
    container.registerSingleton<UserSessionProvider>(
      parent<UserSessionProvider>(),
    );
  }

  @override
  void register(GetIt container) {
    container.registerFactory<TransferViewModel>(() => TransferViewModel(
      repository: container<TransferRepository>(),
    ));
  }
}
```

### Guarantees

- After `init` returns, `container` is accessible and all registrations from `bridge`, `register`, and `afterInit` are committed.
- `init` and `dispose` are each idempotent — repeated calls after the first are no-ops.
- After `dispose` returns, `container` is `null`. Any registration with a `@disposeMethod` has been invoked by `GetIt.reset`.
- `dispose` does not throw even if `afterInit` previously failed.

### Constraints

- `container` MUST NOT be accessed before `init` completes. Accessing it before init throws `StateError`.
- `bridge` MUST forward only the deps this scope actually uses. Forwarding `parent` wholesale bypasses isolation and is an anti-pattern.
- Subclasses MUST NOT call `bridge`, `register`, or `afterInit` directly. These hooks are called exclusively by `init` in a fixed order.
- A disposed scope MUST NOT be re-initialised. Construct a new instance instead.
- `init` is not concurrency-safe. Do not call `init` concurrently or from multiple isolates.

### Failure Behavior

| Hook throws | Effect |
|---|---|
| `bridge` or `register` | `init` propagates the exception; scope is NOT marked initialised; `container` remains `null` |
| `afterInit` | `bridge` / `register` registrations are already committed; exception propagates from `init`; caller MUST call `dispose` |

### Lifecycle

```
init()
  └─ bridge()      ← forward selected parent deps
  └─ register()    ← register scope-local deps
  └─ afterInit()   ← post-registration async work (subscriptions, etc.)
(use container)
dispose()
  └─ onDispose()   ← cleanup hook before GetIt.reset
  └─ GetIt.reset() ← disposes all registered instances
```

### Hook contract

| Hook | When to override | MUST NOT |
|---|---|---|
| `bridge` | Forward parent deps to the scope container | Register scope-local deps here |
| `register` | Register scope-local deps | Call `parent` — use bridged deps only |
| `afterInit` | Subscribe to streams, start timers | Register new deps; call `dispose` |
| `onDispose` | Cancel subscriptions, flush buffers | Throw; it must always succeed |

### Anti-patterns

```dart
// WRONG — forwarding parent wholesale defeats isolation
@override
void bridge(GetIt parent, GetIt container) {
  container.registerSingleton<GetIt>(parent); // ← never do this
}

// WRONG — accessing container before init
final scope = TransferScope(parentContainer: rootGetIt);
scope.container.get<TransferRepository>(); // ← throws StateError

// WRONG — re-using a disposed scope
await scope.dispose();
await scope.init(); // ← construct a new instance instead
```

---

## ScopeWidget / ScopeProvider

Binds an `IsolatedScope` lifetime to a widget subtree. `ScopeWidget` is the **only** sanctioned mechanism for route-tied scopes.

```dart
ScopeWidget<TransferScope>(
  create: () => TransferScope(parentContainer: rootGetIt),
  onInitializing: (_) => const CircularProgressIndicator(),
  builder: (context, scope) => const TransferPage(),
)
```

Within the subtree, read deps via `ScopeProvider.of`:

```dart
class TransferPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final container = ScopeProvider.of(context);
    final viewModel = container<TransferViewModel>();
    return ...;
  }
}
```

### Guarantees

- `builder` is only invoked after `IsolatedScope.init` has completed successfully. The container is fully initialised when `builder` runs.
- `IsolatedScope.dispose` is called exactly once when the `ScopeWidget` leaves the tree, regardless of how the route is dismissed.
- `onInitializing` is shown for the entire duration of `IsolatedScope.init` and replaced by `builder` atomically after init completes.
- The `GetIt` container exposed by `ScopeProvider.of` is stable for the widget's lifetime. Widget rebuilds do NOT change container identity.

### Constraints

- `create` MUST construct a new, uninitialised `IsolatedScope` instance. MUST NOT call `IsolatedScope.init` inside `create`.
- `create` is called exactly once per `ScopeWidget` instance.
- `ScopeWidget` MUST be used for all route-tied scopes. Session-tied scopes that outlive a single route MAY be managed manually in `State`.
- `ScopeProvider.of` MUST only be called from within a widget subtree that is a descendant of a `ScopeWidget` or manually constructed `ScopeProvider`. Calling it outside throws `StateError`.
- Do NOT store the result of `ScopeProvider.of` in a field. Holding a reference beyond the widget lifecycle prevents the scope from being garbage-collected after disposal.

### Failure Behavior

- If `IsolatedScope.init` throws, `ScopeWidget` does not catch the exception. The widget remains in the initialising state. `IsolatedScope.dispose` is still called in `State.dispose` to release any partially-committed registrations.
- `ScopeProvider.of` throws `StateError` if no `ScopeProvider` ancestor exists in the tree. Use `ScopeProvider.maybeOf` when the presence of a `ScopeProvider` is conditional.

### Anti-patterns

```dart
// WRONG — calling init in create
create: () {
  final scope = TransferScope(parentContainer: rootGetIt);
  scope.init(); // ← ScopeWidget owns init
  return scope;
}

// WRONG — reading parent scope container during create
create: () => TransferScope(
  parentContainer: ScopeProvider.of(context), // ← ScopeProvider not yet inserted
)
// FIX: capture the parent container before entering ScopeWidget's create
final parentContainer = ScopeProvider.of(context);
return ScopeWidget(create: () => TransferScope(parentContainer: parentContainer), ...);

// WRONG — sharing a scope instance across multiple ScopeWidgets
final _sharedScope = TransferScope(parentContainer: rootGetIt);
ScopeWidget(create: () => _sharedScope, ...) // ← scope instances are not sharable
```

---

## Architecture Decision Records

### ADR-1: Two-container rule

Each `IsolatedScope` allocates a fresh `GetIt` instance (`GetIt.asNewInstance()`). It does NOT inherit the parent container's registrations. Feature scopes explicitly whitelist the parent deps they need via `bridge`.

**Rationale:** Prevents silent cross-scope dep leakage. A scope that cannot compile without bridging a dep makes the dependency explicit and reviewable.

### ADR-2: ScopeWidget as the only sanctioned route-tier mechanism

`ScopeWidget` calls `init` in `State.initState` and `dispose` in `State.dispose`. Manual scope management in `State` is permitted only for session-tied scopes (e.g. `AuthScope`) that span multiple routes.

**Rationale:** Centralising the lifecycle binding in one widget class prevents the "init called but dispose forgotten" class of bugs.

### ADR-3: DiBoot warmUp is fire-and-forget by design

`warmUp` does not return a `Future` and warmup exceptions are swallowed. Non-critical services (analytics, crash reporting) must not gate `runApp`.

**Rationale:** Blocking startup on non-critical services degrades cold-start performance. Non-critical services must tolerate their own initialisation failures gracefully (pre-ready calls are dropped, not queued).

---

## Package structure

```
lib/
  di.dart               # Public barrel — exports all primitives
  src/
    di_boot.dart        # DiBoot
    isolated_scope.dart # IsolatedScope
    scope_provider.dart # ScopeProvider (InheritedWidget)
    scope_widget.dart   # ScopeWidget (StatefulWidget)
```
