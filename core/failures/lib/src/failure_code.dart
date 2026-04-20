// public API already self-explanatory, no need for docs
// ignore_for_file: public_member_api_docs

import 'package:flutter/foundation.dart';

/// Typed failure code identifying a specific error condition.
///
/// Provides a type-safe alternative to raw strings while remaining
/// extensible — feature packages can define domain-specific codes
/// without modifying this core library.
///
/// ```dart
/// // Use predefined constants for common failures:
/// FailureCode.timeout
///
/// // Define feature-specific codes in your own package:
/// const transferLimitExceeded = FailureCode('TRANSFER_LIMIT_EXCEEDED');
/// ```
@immutable
final class FailureCode {
  /// Creates a [FailureCode] with the given string value.
  const FailureCode(this.value);

  /// Creates a [FailureCode] from a backend error code string.
  ///
  /// Use when the backend returns a structured error code that should
  /// be preserved verbatim in the failure model.
  const factory FailureCode.fromBackend(String backendCode) = FailureCode;

  /// The string identifier for this failure code.
  final String value;

  // ── Network ──────────────────────────────────────────────────────────

  static const noConnection = FailureCode('NETWORK_NO_CONNECTION');
  static const timeout = FailureCode('NETWORK_TIMEOUT');
  static const requestCancelled = FailureCode('NETWORK_REQUEST_CANCELLED');

  // ── Server ───────────────────────────────────────────────────────────

  static const serverError = FailureCode('SERVER_ERROR');
  static const serviceUnavailable = FailureCode('SERVER_SERVICE_UNAVAILABLE');
  static const badGateway = FailureCode('SERVER_BAD_GATEWAY');
  static const gatewayTimeout = FailureCode('SERVER_GATEWAY_TIMEOUT');

  // ── Authentication ───────────────────────────────────────────────────

  static const unauthenticated = FailureCode('AUTH_UNAUTHENTICATED');
  static const tokenExpired = FailureCode('AUTH_TOKEN_EXPIRED');
  static const sessionExpired = FailureCode('AUTH_SESSION_EXPIRED');
  static const invalidCredentials = FailureCode('AUTH_INVALID_CREDENTIALS');

  // ── Authorization ────────────────────────────────────────────────────

  static const forbidden = FailureCode('AUTHZ_FORBIDDEN');
  static const insufficientPermissions = FailureCode('AUTHZ_INSUFFICIENT_PERMISSIONS');

  // ── Business Rule ────────────────────────────────────────────────────

  static const businessRuleViolation = FailureCode('BUSINESS_RULE_VIOLATION');

  // ── Validation ───────────────────────────────────────────────────────

  static const validationFailed = FailureCode('VALIDATION_FAILED');

  // ── Security ─────────────────────────────────────────────────────────

  static const certificateInvalid = FailureCode('SECURITY_CERTIFICATE_INVALID');
  static const deviceIntegrityFailed = FailureCode('SECURITY_DEVICE_INTEGRITY');
  static const tamperedPayload = FailureCode('SECURITY_TAMPERED_PAYLOAD');

  // ── Persistence ──────────────────────────────────────────────────────

  static const readFailed = FailureCode('PERSISTENCE_READ_FAILED');
  static const writeFailed = FailureCode('PERSISTENCE_WRITE_FAILED');
  static const deleteFailed = FailureCode('PERSISTENCE_DELETE_FAILED');
  static const migrationFailed = FailureCode('PERSISTENCE_MIGRATION_FAILED');

  // ── System ───────────────────────────────────────────────────────────

  static const unknown = FailureCode('SYSTEM_UNKNOWN');
  static const unexpected = FailureCode('SYSTEM_UNEXPECTED');  static const parseError = FailureCode('SYSTEM_PARSE_ERROR');
  
  @override
  bool operator ==(Object other) => identical(this, other) || other is FailureCode && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
