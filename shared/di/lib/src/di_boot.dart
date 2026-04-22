import 'dart:async';

import 'package:get_it/get_it.dart';

/// Enforces the two-phase root [GetIt] container bootstrap protocol.
///
/// ## Guarantees
/// - After [run] returns, every registration annotated `@preResolve` or
///   `@singleton` with async initialisation is fully resolved.
/// - [warmUp] tasks execute in independent microtasks and never block [runApp]
///   or the first frame.
/// - [warmUp] is fire-and-forget: it does not return a [Future] and callers
///   MUST NOT assume any warmup has completed after [warmUp] returns.
///
/// ## Constraints
/// - [run] MUST be awaited to completion before [runApp] is called.
/// - [warmUp] MUST be called after [runApp], not before.
/// - Both methods accept the same [container] instance; passing different
///   containers to [run] and [warmUp] is a programming error.
/// - [run] and [warmUp] are NOT idempotent. Calling [run] twice on an
///   already-initialised container will cause duplicate registrations.
///
/// ## Failure Behavior
/// - If [init] throws, the exception propagates out of [run] unchanged.
///   The container is left in a partially-initialised state. The application
///   MUST NOT call [runApp] and MUST terminate or show a fatal error screen.
/// - If a warmup throws, the exception is swallowed (fire-and-forget semantics).
///   Individual warmup failures do not affect other warmups or the app lifecycle.
///
/// ## Concurrency
/// - [run] is not concurrency-safe. Only one call to [run] may be in flight
///   at a time. Concurrent calls produce undefined behaviour.
/// - [warmUp] tasks run concurrently with each other and with the Flutter
///   engine. Each task is isolated in its own [Future] microtask.
///
/// ## Lifecycle
/// Strict call order: [run] → [runApp] → [warmUp].
/// Calling [warmUp] before [run] completes exposes warmup tasks to a
/// partially-initialised container and is a programming error.
///
/// ## Anti-pattern
/// Do NOT access the container from warmup callbacks for synchronous work.
/// Warmups exist solely to trigger lazy construction. Any computation on
/// the resolved instance belongs in the instance's own initialiser.
final class DiBoot {
  /// Creates a new [DiBoot] with the given initialisation and warmup tasks.
  ///
  /// [init] is the critical path: it is awaited before the app starts and
  /// must complete before the first frame. It should register all critical
  /// dependencies, especially those with async initialisation.
  ///
  /// [warmups] are non-critical tasks that run after the first frame. They
  /// should trigger lazy construction of non-critical dependencies (e.g.
  /// analytics) but MUST NOT perform any critical synchronous work on the
  /// resolved instances. Warmups are fire-and-forget and do not block app
  /// startup.
  const DiBoot({
    required Future<void> Function(GetIt container) init,
    List<void Function(GetIt container)> warmups = const [],
  })  : _init = init,
        _warmups = warmups;

  final Future<void> Function(GetIt) _init;
  final List<void Function(GetIt)> _warmups;

  /// Executes the blocking initialisation phase.
  ///
  /// ## Guarantees
  /// Returns only after [init] resolves and all `@preResolve` / async
  /// singletons are accessible via the container.
  ///
  /// ## Constraints
  /// Must be awaited. Must be called exactly once per container lifetime.
  ///
  /// ## Failure Behavior
  /// Propagates any exception thrown by [init] to the caller.
  /// The container is unusable if this method throws.
  Future<void> run(GetIt container) => _init(container);

  /// Triggers fire-and-forget construction of non-critical lazy singletons.
  ///
  /// ## Guarantees
  /// Each registered warmup is scheduled as an independent [Future] microtask.
  /// Returns synchronously; no warmup is guaranteed to have started or
  /// completed by the time this method returns.
  ///
  /// ## Constraints
  /// Must be called after [runApp]. Calling before [run] completes is
  /// a programming error.
  ///
  /// ## Failure Behavior
  /// Exceptions thrown inside individual warmup tasks are silently swallowed.
  /// A failing warmup does not affect the application lifecycle or other warmups.
  void warmUp(GetIt container) {
    for (final task in _warmups) {
      unawaited(Future<void>(() => task(container)));
    }
  }
}
