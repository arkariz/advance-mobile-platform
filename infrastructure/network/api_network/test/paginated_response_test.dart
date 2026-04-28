import 'package:api_network/src/response/response.dart';
import 'package:test/test.dart';

void main() {
  group('PaginatedResponse', () {
    test('should parse paginated response', () {
      final json = {
        'code': 200,
        'data': [
          'item1',
          'item2',
        ],
        'pagination': {
          'total_items': 2,
          'total_pages': 1,
          'current_page': 1,
          'items_per_page': 10,
        }
      };

      final result = PaginatedResponse<String>.fromJson(
        json,
        (json) => json! as String,
      );

      expect(result.statusCode, 200);

      expect(result.data, hasLength(2));
      expect(result.data?[0], 'item1');
      expect(result.data?[1], 'item2');

      expect(result.pagination?.totalItems, 2);
      expect(result.pagination?.totalPages, 1);
      expect(result.pagination?.currentPage, 1);
      expect(result.pagination?.itemsPerPage, 10);
    });

    test('should parse empty list', () {
      final json = {
        'code': 200,
        'data': <Object>[],
        'pagination': {
          'total_items': 0,
          'total_pages': 0,
          'current_page': 1,
          'items_per_page': 10,
        }
      };

      final result = PaginatedResponse<String>.fromJson(
        json,
        (json) => json! as String,
      );

      expect(result.data, isEmpty);
      expect(result.pagination?.totalItems, 0);
    });

    test('should handle null pagination', () {
      final json = {
        'code': 200,
        'data': ['item1'],
        'pagination': null,
      };

      final result = PaginatedResponse<String>.fromJson(
        json,
        (json) => json! as String,
      );

      expect(result.pagination, isNull);
    });
  });

  group('PaginationResponse', () {
    test('should parse pagination object', () {
      final json = {
        'total_items': 100,
        'total_pages': 10,
        'current_page': 2,
        'items_per_page': 10,
      };

      final result = PaginationResponse.fromJson(json);

      expect(result.totalItems, 100);
      expect(result.totalPages, 10);
      expect(result.currentPage, 2);
      expect(result.itemsPerPage, 10);
    });
  });
}
