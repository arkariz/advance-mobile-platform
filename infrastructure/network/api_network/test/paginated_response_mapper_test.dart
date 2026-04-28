import 'package:api_network/src/response/response.dart';
import 'package:models/models.dart';
import 'package:test/test.dart';

void main() {
  late PaginatedResponseMapper mapper;

  setUp(() {
    mapper = PaginatedResponseMapper();
  });

  group('PaginatedResponseMapper', () {
    test('maps full JSON to Paginated<T> correctly', () {
      final json = {
        'data': ['a', 'b', 'c'],
        'pagination': {
          'total_items': 10,
          'total_pages': 4,
          'current_page': 1,
          'items_per_page': 3,
        },
      };

      final result = mapper.map<String>(json);

      expect(result, isA<Paginated<String>>());
      expect(result.items, ['a', 'b', 'c']);
      expect(result.totalItems, 10);
      expect(result.totalPages, 4);
      expect(result.currentPage, 1);
      expect(result.itemsPerPage, 3);
    });

    test('maps empty data list to empty items', () {
      final json = {
        'data': <dynamic>[],
        'pagination': {
          'total_items': 0,
          'total_pages': 0,
          'current_page': 1,
          'items_per_page': 10,
        },
      };

      final result = mapper.map<String>(json);

      expect(result.items, isEmpty);
      expect(result.totalItems, 0);
      expect(result.totalPages, 0);
    });

    test('defaults to 0 when pagination is null', () {
      final json = {
        'data': ['x'],
        'pagination': null,
      };

      final result = mapper.map<String>(json);

      expect(result.totalItems, 0);
      expect(result.totalPages, 0);
      expect(result.currentPage, 0);
      expect(result.itemsPerPage, 0);
    });

    test('defaults to empty list when data is null', () {
      final json = {
        'data': null,
        'pagination': {
          'total_items': 5,
          'total_pages': 1,
          'current_page': 1,
          'items_per_page': 5,
        },
      };

      final result = mapper.map<String>(json);

      expect(result.items, isEmpty);
    });

    test('maps paginated response with Map items', () {
      final json = {
        'data': [
          {'id': 1, 'name': 'Alice'},
          {'id': 2, 'name': 'Bob'},
        ],
        'pagination': {
          'total_items': 2,
          'total_pages': 1,
          'current_page': 1,
          'items_per_page': 10,
        },
      };

      final result = mapper.map<Map<String, dynamic>>(json);

      expect(result.items.length, 2);
      expect(result.items.first['name'], 'Alice');
      expect(result.items.last['id'], 2);
    });

    test('returns Paginated equal to expected value', () {
      final json = {
        'data': [1, 2],
        'pagination': {
          'total_items': 2,
          'total_pages': 1,
          'current_page': 1,
          'items_per_page': 2,
        },
      };

      final result = mapper.map<int>(json);

      const expected = Paginated<int>(
        items: [1, 2],
        totalItems: 2,
        totalPages: 1,
        currentPage: 1,
        itemsPerPage: 2,
      );

      expect(result, equals(expected));
    });
  });
}
