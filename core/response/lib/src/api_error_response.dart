import 'package:dependencies/dependencies.dart';

part 'api_error_response.g.dart';

/// A response model for API errors, containing error details such as 
/// code, message, user-friendly message, and trace ID.
@JsonSerializable()
class ApiErrorResponse {
  /// Creates an instance of [ApiErrorResponse] with the given parameters.
  ApiErrorResponse({
    required this.code,
    this.message,
    this.userMessage,
    this.traceId,
  });

  /// Creates an instance of [ApiErrorResponse] from a JSON map.
  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) => _$ApiErrorResponseFromJson(json);

  /// Standardized error code representing the type of error.
  final String code;
  
  /// A detailed error message for debugging purposes.
  final String? message;

  /// A user-friendly error message that can be displayed in the UI.
  final String? userMessage;

  /// A unique identifier for the error instance for tracing and debugging.
  final String? traceId;
}
