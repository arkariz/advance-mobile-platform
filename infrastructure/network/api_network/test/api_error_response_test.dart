import 'package:api_network/src/response/response.dart';
import 'package:test/test.dart';

void main() {
  group('ApiErrorResponse', () {
    test('should parse full error response', () {
      final json = {
        'code': 'INVALID_TOKEN',
        'message': 'Token expired',
        'user_message': 'Please login again',
        'trace_id': 'trace-123',
      };

      final result = ApiErrorResponse.fromJson(json);

      expect(result.code, 'INVALID_TOKEN');
      expect(result.message, 'Token expired');
      expect(result.userMessage, 'Please login again');
      expect(result.traceId, 'trace-123');
    });

    test('should parse required field only', () {
      final json = {
        'code': 'UNKNOWN_ERROR',
      };

      final result = ApiErrorResponse.fromJson(json);

      expect(result.code, 'UNKNOWN_ERROR');
      expect(result.message, isNull);
      expect(result.userMessage, isNull);
      expect(result.traceId, isNull);
    });

    test('should throw when code is missing', () {
      final json = {
        'message': 'error',
      };

      expect(
        () => ApiErrorResponse.fromJson(json),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
