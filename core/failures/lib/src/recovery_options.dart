//
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:failures/failures.dart';

/// Describes how the client should respond to a [Failure].
///
/// Encapsulates recovery behavior so the presentation layer can
/// determine the appropriate UX without inspecting failure internals.
///
/// ```dart
/// if (failure.recovery.requiresReAuthentication) {
///   navigator.pushReplacementNamed('/login');
/// } else if (failure.recovery.isRetryable) {
///   showRetryDialog();
/// }
/// ```
final class RecoveryOptions {
  /// Creates a [RecoveryOptions] with the given fields.
  const RecoveryOptions({
    this.isRetryable = false,
    this.requiresReAuthentication = false,
  });

  /// Whether the failed operation can be retried with a reasonable
  /// expectation of success (e.g., transient network error).
  final bool isRetryable;

  /// Whether the user's session is invalid and they must
  /// re-authenticate before continuing.
  final bool requiresReAuthentication;

  /// No recovery action is available.
  static const none = RecoveryOptions();

  /// The operation can be retried.
  static const retryable = RecoveryOptions(isRetryable: true);

  /// The user must re-authenticate.
  static const reAuthenticate = RecoveryOptions(
    requiresReAuthentication: true,
  );

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is RecoveryOptions &&
      isRetryable == other.isRetryable &&
      requiresReAuthentication == other.requiresReAuthentication;

  @override
  int get hashCode => Object.hash(isRetryable, requiresReAuthentication);

  @override
  String toString() =>
    'RecoveryOptions(isRetryable: $isRetryable, '
    'requiresReAuthentication: $requiresReAuthentication)';
}
