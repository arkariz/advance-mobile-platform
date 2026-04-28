import 'package:api_network/src/response/response.dart';
import 'package:test/test.dart';

void main() {
  group('ObjectResponse', () {
    test('should parse primitive data', () {
      final json = {
        'code': 200,
        'data': 'hello',
      };

      final result = ObjectResponse<String>.fromJson(
        json,
        (json) => json! as String,
      );

      expect(result.statusCode, 200);
      expect(result.data, 'hello');
    });

    test('should parse map object', () {
      final json = {
        'code': 200,
        'data': {
          'id': 1,
          'name': 'John',
        }
      };

      final result = ObjectResponse<Map<String, dynamic>>.fromJson(
        json,
        (json) => json! as Map<String, dynamic>,
      );

      expect(result.statusCode, 200);
      expect(result.data?['id'], 1);
      expect(result.data?['name'], 'John');
    });

    test('should handle null data', () {
      final json = {
        'code': 204,
        'data': null,
      };

      final result = ObjectResponse<String?>.fromJson(
        json,
        (json) => json as String?,
      );

      expect(result.statusCode, 204);
      expect(result.data, isNull);
    });

    test('should handle null status code', () {
      final json = {
        'data': 'test',
      };

      final result = ObjectResponse<String>.fromJson(
        json,
        (json) => json! as String,
      );

      expect(result.statusCode, isNull);
      expect(result.data, 'test');
    });
  });
}
