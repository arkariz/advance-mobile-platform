/// Core failure model mapping for the domain layer.
///
/// Provides:
/// - A sealed [Failure] hierarchy for exhaustive error handling
/// - [FailureCode] for typed, extensible error identification
/// - [FailureDetails] for infrastructure observability metadata
/// - [RecoveryOptions] for client-side recovery behavior
/// - [RestApiHandler] contract for transport-agnostic API execution
///
/// ## Quick Example
///
/// ```dart
/// Future<T> runApi<T>(RestApiHandler rest, Future<T> Function() request) {
///   return rest.handle(request);
/// }
/// ```
library;

import 'package:failures/src/failure.dart';
import 'package:failures/src/failure_code.dart';
import 'package:failures/src/failure_details.dart';
import 'package:failures/src/recovery_options.dart';
import 'package:failures/src/rest_api_handler.dart';

export 'src/failure.dart';
export 'src/failure_code.dart';
export 'src/failure_details.dart';
export 'src/recovery_options.dart';
export 'src/rest_api_handler.dart';
