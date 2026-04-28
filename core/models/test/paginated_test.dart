import 'package:models/models.dart';
import 'package:test/test.dart';

void main() {
  group('Paginated', () {
    test('creates instance with given values', () {
      const paginated = Paginated(
        items: [1, 2, 3],
        totalItems: 10,
        totalPages: 4,
        currentPage: 1,
        itemsPerPage: 3,
      );

      expect(paginated.items, [1, 2, 3]);
      expect(paginated.totalItems, 10);
      expect(paginated.totalPages, 4);
      expect(paginated.currentPage, 1);
      expect(paginated.itemsPerPage, 3);
    });

    test('empty() creates instance with default zero values', () {
      final paginated = Paginated<String>.empty();

      expect(paginated.items, isEmpty);
      expect(paginated.totalItems, 0);
      expect(paginated.totalPages, 0);
      expect(paginated.currentPage, 0);
      expect(paginated.itemsPerPage, 0);
    });

    test('supports equality when values are the same', () {
      const a = Paginated(
        items: ['x'],
        totalItems: 1,
        totalPages: 1,
        currentPage: 1,
        itemsPerPage: 1,
      );

      const b = Paginated(
        items: ['x'],
        totalItems: 1,
        totalPages: 1,
        currentPage: 1,
        itemsPerPage: 1,
      );

      expect(a, equals(b));
    });

    test('not equal when items differ', () {
      const a = Paginated(
        items: ['x'],
        totalItems: 1,
        totalPages: 1,
        currentPage: 1,
        itemsPerPage: 1,
      );

      const b = Paginated(
        items: ['y'],
        totalItems: 1,
        totalPages: 1,
        currentPage: 1,
        itemsPerPage: 1,
      );

      expect(a, isNot(equals(b)));
    });

    test('not equal when pagination metadata differs', () {
      const a = Paginated(
        items: <int>[],
        totalItems: 10,
        totalPages: 2,
        currentPage: 1,
        itemsPerPage: 5,
      );

      const b = Paginated(
        items: <int>[],
        totalItems: 20,
        totalPages: 4,
        currentPage: 2,
        itemsPerPage: 5,
      );

      expect(a, isNot(equals(b)));
    });

    test('props contains all fields', () {
      const paginated = Paginated(
        items: [42],
        totalItems: 1,
        totalPages: 1,
        currentPage: 1,
        itemsPerPage: 1,
      );

      expect(
        paginated.props,
        [
          [42],
          1,
          1,
          1,
          1,
        ],
      );
    });

    test('supports generic type with objects', () {
      const paginated = Paginated(
        items: [
          {'id': 1},
          {'id': 2},
        ],
        totalItems: 2,
        totalPages: 1,
        currentPage: 1,
        itemsPerPage: 2,
      );

      expect(paginated.items.length, 2);
      expect(paginated.items.first['id'], 1);
    });
  });
}
