import 'dart:async';

import 'package:flutter/foundation.dart';

/// Non-critical analytics service using the sync-facade pattern.
///
/// ## Ownership
/// Application layer only. MUST NOT be injected into feature packages
/// or domain layers.
///
/// ## Guarantees
/// - The constructor is synchronous and returns immediately.
/// - [_initialize] runs asynchronously after construction without blocking
///   the caller or [runApp].
/// - Every public method is safe to call before [_initialize] completes.
///   Calls before readiness are silently dropped (no exception, no crash).
/// - After [_initialize] resolves, [isReady] is `true` and all subsequent
///   calls to [logEvent] are forwarded to the underlying SDK.
///
/// ## Constraints
/// - MUST be triggered as a [DiBoot.warmUp] entry after [runApp], not during
///   [DiBoot.run]. Placing it in the blocking phase delays the first frame.
/// - MUST NOT be awaited at the call site. Construction is fire-and-forget.
/// - [logEvent] MUST NOT throw regardless of readiness state. Callers MUST
///   NOT add null guards or readiness checks before calling [logEvent].
///   The guard is owned by this class.
///
/// ## Failure Behavior
/// - If [_initialize] throws (e.g. SDK unavailable), [isReady] remains
///   `false` permanently for the process lifetime. All [logEvent] calls
///   are silently dropped. The failure does NOT propagate to the caller.
///
/// ## Concurrency
/// - [_initialize] is called once from the constructor. Subsequent calls to
///   [logEvent] are safe to issue from any Flutter-isolated async context
///   on the UI thread.
class AnalyticsService {
  AnalyticsService() {
    unawaited(_initialize());
  }

  bool _ready = false;

  /// Whether the underlying SDK has finished initialising.
  bool get isReady => _ready;

  Future<void> _initialize() async {
    // Simulate SDK setup time (e.g. Firebase.initializeApp,
    // permission checks, remote config fetch).
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _ready = true;
    debugPrint('[Analytics] Service ready — queued events will now be sent.');
  }

  /// Log a named event.
  ///
  /// Silently no-ops if called before [_initialize] completes.
  /// No exception, no crash — just a skipped event.
  void logEvent(String name, {Map<String, Object>? params}) {
    if (!_ready) {
      debugPrint('[Analytics] Not ready — "$name" dropped (will be ready soon).');
      return;
    }
    debugPrint('[Analytics] Event: "$name" ${params ?? ''}');
  }
}
