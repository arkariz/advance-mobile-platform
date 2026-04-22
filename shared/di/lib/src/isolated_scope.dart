import 'package:get_it/get_it.dart';

/// Base class for all feature-level DI scopes with an independently isolated [GetIt] container.
///
/// Each scope allocates a fresh [GetIt.asNewInstance()] that shares NO registrations
/// with [parent] unless explicitly forwarded via [bridge]. This enforces the
/// two-container rule: a scope cannot access any parent registration that was
/// not whitelisted.
///
/// ## Guarantees
/// - After [init] returns, [container] is accessible and all registrations
///   from [bridge], [register], and [afterInit] are complete.
/// - After [dispose] returns, [container] is null. Any registration with a
///   `@disposeMethod` has been invoked by [GetIt.reset].
/// - [init] and [dispose] are each idempotent: repeated calls after the first
///   are no-ops.
///
/// ## Constraints
/// - [container] MUST NOT be accessed before [init] completes. Doing so throws
///   [StateError].
/// - [bridge] MUST forward only the deps this scope actually uses. Forwarding
///   [parent] wholesale bypasses the isolation guarantee and is an anti-pattern.
/// - Subclasses MUST NOT call [bridge], [register], or [afterInit] directly.
///   These hooks are called exclusively by [init] in a fixed order.
/// - A disposed scope MUST NOT be re-initialised. Construct a new instance instead.
///
/// ## Failure Behavior
/// - If [bridge] or [register] throws, the container is left partially
///   populated. [init] propagates the exception; the scope is NOT marked
///   as initialised and [container] remains null.
/// - If [afterInit] throws, registrations from [bridge] and [register] are
///   already committed to the container. The exception propagates from [init].
///   The caller MUST call [dispose] to release the container.
/// - [dispose] does not throw if [afterInit] previously failed; it is always
///   safe to call.
///
/// ## Concurrency
/// - [init] is not concurrency-safe. Concurrent calls from multiple isolates
///   or concurrent [Future] chains are a programming error.
/// - [dispose] is not concurrency-safe. Do not call [dispose] while [init]
///   is still in flight.
///
/// ## Lifecycle
/// Required call order: `init()` → (use [container]) → `dispose()`.
/// Hooks are invoked by [init] in this fixed order: [bridge] → [register] → [afterInit].
///
/// ## Anti-pattern
/// - Do NOT pass [parent] directly to scope-local registrations instead of
///   explicitly bridging each dep. Hidden parent coupling defeats isolation.
/// - Do NOT store a reference to [container] outside the scope class. All
///   container access must go through [IsolatedScope.container] or
///   [ScopeProvider.of] in the widget layer.
abstract base class IsolatedScope {
  /// Creates a new [IsolatedScope] with the given parent container.
  ///
  /// [parent] is the container of the parent scope. It is not automatically forwarded to the scope-local container;
  /// the scope MUST explicitly bridge any required parent deps in [bridge].
  IsolatedScope({required GetIt parentContainer}) : _parent = parentContainer;

  final GetIt _parent;
  GetIt? _container;

  /// The parent container passed at construction.
  ///
  /// Accessible inside hook methods only. MUST NOT be exposed publicly
  /// by subclasses, as doing so would allow consumers to bypass isolation.
  GetIt get parent => _parent;

  /// The scope-local container.
  ///
  /// ## Constraints
  /// Accessible only between a successful [init] call and [dispose].
  /// Throws [StateError] if accessed outside that window.
  GetIt get container {
    final c = _container;
    if (c == null) throw StateError('$runtimeType is not initialised.');
    return c;
  }

  /// Whether this scope has been successfully initialised and not yet disposed.
  bool get isInitialised => _container != null;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  /// Initialises this scope by invoking hooks in order: [bridge] → [register] → [afterInit].
  ///
  /// ## Guarantees
  /// Returns only after [afterInit] resolves. All registrations are accessible
  /// via [container] immediately after this method returns.
  ///
  /// ## Constraints
  /// Idempotent — subsequent calls on an already-initialised scope are no-ops.
  /// Must not be called concurrently or after [dispose].
  ///
  /// ## Failure Behavior
  /// If any hook throws, the exception propagates from [init]. The scope is
  /// NOT marked as initialised. If [afterInit] throws after [bridge]/[register]
  /// have run, the caller MUST call [dispose] to reset the container.
  Future<void> init() async {
    if (_container != null) return;
    _container = GetIt.asNewInstance();
    bridge(_container!);
    register(_container!);
    await afterInit();
  }

  /// Disposes this scope and resets its container.
  ///
  /// ## Guarantees
  /// After this method returns, [container] is null and all registered
  /// instances with a `@disposeMethod` have been released.
  ///
  /// ## Constraints
  /// Idempotent — safe to call on an uninitialised or already-disposed scope.
  /// MUST NOT be called concurrently with [init].
  Future<void> dispose() async {
    if (_container == null) return;
    onDispose();
    await _container!.reset();
    _container = null;
  }

  // ── Hooks ─────────────────────────────────────────────────────────────────

  /// Whitelists the deps from [parent] that this scope requires.
  ///
  /// ## Constraints
  /// - Required. MUST be overridden in every concrete scope.
  /// - MUST register only deps this scope actually uses. Forwarding the
  ///   entire [parent] container is an anti-pattern that defeats isolation.
  /// - MUST NOT be called directly. Invoked by [init].
  void bridge(GetIt c);

  /// Registers scope-local deps not sourced from [parent].
  ///
  /// ## Constraints
  /// - Optional. Default is a no-op.
  /// - MUST NOT access [parent] directly. Use only the scope-local [c].
  /// - MUST NOT be called directly. Invoked by [init] after [bridge].
  void register(GetIt c) {}

  /// Performs async setup after the container is fully populated.
  ///
  /// ## Constraints
  /// - Optional. Default is a no-op.
  /// - MUST NOT call [bridge] or [register]. The container is already sealed.
  /// - MUST NOT be called directly. Invoked by [init] after [register].
  ///
  /// ## Failure Behavior
  /// If this method throws, [bridge] and [register] have already committed
  /// their registrations. The caller MUST invoke [dispose] to reset the
  /// container and avoid a resource leak.
  Future<void> afterInit() async {}

  /// Performs synchronous cleanup immediately before [GetIt.reset].
  ///
  /// ## Constraints
  /// - Optional. Default is a no-op.
  /// - MUST be synchronous. Async cleanup belongs in `@disposeMethod`
  ///   annotations on registered instances, which [GetIt.reset] invokes.
  /// - MUST NOT be called directly. Invoked by [dispose].
  void onDispose() {}
}
