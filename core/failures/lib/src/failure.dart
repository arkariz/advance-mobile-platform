import 'package:failures/failures.dart';

/// Root abstraction for all domain-layer failures.
///
/// Every infrastructure exception must be mapped to a [Failure] subtype
/// before crossing into the domain layer. This ensures the domain remains
/// fully decoupled from infrastructure concerns (HTTP, storage, biometric).
///
/// ## Taxonomy
///
/// The sealed hierarchy enforces exhaustive handling:
///
/// | Family | When to use |
/// |---|---|
/// | [NetworkFailure] | Connectivity, timeout, DNS, request cancelled |
/// | [ServerFailure] | HTTP 5xx, bad gateway, service unavailable |
/// | [AuthenticationFailure] | 401, token/session expiry, invalid credentials |
/// | [AuthorizationFailure] | 403, insufficient roles/permissions |
/// | [BusinessRuleFailure] | Backend domain logic violations |
/// | [ValidationFailure] | Input/field validation errors |
/// | [SecurityFailure] | Certificate pinning, device integrity, tampering |
/// | [PersistenceFailure] | Local DB, secure storage, cache errors |
/// | [SystemFailure] | Unknown/unexpected errors |
///
/// ## Usage
///
/// ```dart
/// final widget = switch (failure) {
///   NetworkFailure()        => const NoConnectionView(),
///   AuthenticationFailure() => const SessionExpiredView(),
///   ValidationFailure(:final fieldErrors) => FormErrorView(fieldErrors),
///   _                       => GenericErrorView(failure.userMessage),
/// };
/// ```
sealed class Failure {
  const Failure({
    required this.code,
    required this.message,
    this.userMessage,
    this.recovery = RecoveryOptions.none,
    this.details,
  });

  /// Typed code identifying the specific error condition.
  final FailureCode code;

  /// Developer-facing diagnostic message.
  ///
  /// **Security:** Must never be displayed to users. May contain
  /// internal service names, SQL fragments, or stack trace details.
  final String message;

  /// User-safe message suitable for UI display.
  ///
  /// Null when no user-appropriate message is available; the
  /// presentation layer should fall back to a generic message.
  final String? userMessage;

  /// Describes how the client should respond to this failure.
  final RecoveryOptions recovery;

  /// Infrastructure metadata for observability and debugging.
  final FailureDetails? details;

  @override
  String toString() =>
    // 
    // ignore: no_runtimetype_tostring
    '$runtimeType(code: $code, message: $message, '
    'recovery: $recovery, details: $details)';
}

// ── Network ──────────────────────────────────────────────────────────────

/// Failure due to network connectivity issues.
///
/// Covers: no internet, DNS resolution failure, connection timeout,
/// send/receive timeout, request cancellation.
final class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure] with the given fields.
  const NetworkFailure({
    required super.code,
    required super.message,
    super.userMessage,
    super.recovery,
    super.details,
  });
}

// ── Server ───────────────────────────────────────────────────────────────

/// Failure due to a server-side error (HTTP 5xx).
final class ServerFailure extends Failure {
  /// Creates a [ServerFailure] with the given fields.
  const ServerFailure({
    required super.code,
    required super.message,
    super.userMessage,
    super.recovery,
    super.details,
  });
}

// ── Authentication ───────────────────────────────────────────────────────

/// Failure due to invalid or expired authentication state.
///
/// Typically mapped from HTTP 401 responses. Defaults to
/// [RecoveryOptions.reAuthenticate] since the user's session
/// is no longer valid.
final class AuthenticationFailure extends Failure {
  /// Creates an [AuthenticationFailure] with the given fields.
  const AuthenticationFailure({
    required super.code,
    required super.message,
    super.userMessage,
    super.recovery = RecoveryOptions.reAuthenticate,
    super.details,
  });
}

// ── Authorization ────────────────────────────────────────────────────────

/// Failure due to insufficient permissions or roles.
///
/// Typically mapped from HTTP 403 responses.
final class AuthorizationFailure extends Failure {
  /// Creates an [AuthorizationFailure] with the given fields.
  const AuthorizationFailure({
    required super.code,
    required super.message,
    super.userMessage,
    super.recovery,
    super.details,
  });
}

// ── Business Rule ────────────────────────────────────────────────────────

/// Failure due to a backend business rule violation.
///
/// Examples: insufficient balance, transaction limit exceeded,
/// account frozen, duplicate transaction.
final class BusinessRuleFailure extends Failure {
  /// Creates a [BusinessRuleFailure] with the given fields.
  const BusinessRuleFailure({
    required super.code,
    required super.message,
    super.userMessage,
    super.recovery,
    super.details,
  });
}

// ── Validation ───────────────────────────────────────────────────────────

/// Failure due to input validation errors.
///
/// Carries structured [fieldErrors] for form-level error display.
///
/// ```dart
/// case ValidationFailure(:final fieldErrors):
///   for (final MapEntry(:key, :value) in fieldErrors.entries) {
///     formKey.currentState?.fields[key]?.invalidate(value.first);
///   }
/// ```
final class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure] with the given fields.
  const ValidationFailure({
    required super.code,
    required super.message,
    super.userMessage,
    super.recovery,
    super.details,
    this.fieldErrors = const {},
  });

  /// Per-field validation error messages.
  ///
  /// Keys are field identifiers (matching form field names),
  /// values are lists of validation messages for that field.
  final Map<String, List<String>> fieldErrors;

  @override
  String toString() =>
      'ValidationFailure(code: $code, message: $message, '
      'fieldErrors: $fieldErrors)';
}

// ── Security ─────────────────────────────────────────────────────────────

/// Failure due to a security violation.
///
/// Covers: SSL certificate pinning failure, device integrity/root detection,
/// payload tampering, jailbreak detection.
///
/// Security failures should be reported to the security monitoring
/// pipeline and are never retryable by default.
final class SecurityFailure extends Failure {
  /// Creates a [SecurityFailure] with the given fields.
  const SecurityFailure({
    required super.code,
    required super.message,
    super.userMessage,
    super.recovery,
    super.details,
  });
}

// ── Persistence ──────────────────────────────────────────────────────────

/// Failure originating from local data operations.
///
/// Covers: SQLite errors, shared preferences, secure storage
/// (Keychain/Keystore), file I/O, cache layer.
final class PersistenceFailure extends Failure {
  /// Creates a [PersistenceFailure] with the given fields.
  const PersistenceFailure({
    required super.code,
    required super.message,
    super.userMessage,
    super.recovery,
    super.details,
  });
}

// ── System ───────────────────────────────────────────────────────────────

/// Catch-all for unexpected or unclassifiable failures.
///
/// Use only when no other failure family applies. If you find yourself
/// creating many [SystemFailure] instances, consider whether a new
/// failure family is warranted.
final class SystemFailure extends Failure {
  /// Creates a [SystemFailure] with the given fields.
  const SystemFailure({
    required super.code,
    required super.message,
    super.userMessage,
    super.recovery,
    super.details,
  });
}
