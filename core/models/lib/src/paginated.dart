import 'package:dependencies/dependencies.dart';

/// A class representing a paginated response containing a list of items and pagination metadata.
class Paginated<T> extends Equatable {
  /// Creates an instance of [Paginated] with the given parameters.
  const Paginated({
    required this.items,
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.itemsPerPage,
  });

  /// Creates an empty instance of [Paginated] with default values.
  factory Paginated.empty() {
    return const Paginated(
      items: [],
      totalItems: 0,
      totalPages: 0,
      currentPage: 0,
      itemsPerPage: 0,
    );
  }

  /// A list of items contained in the current page of the response.
  final List<T> items;

  /// The total number of items available across all pages.
  final int totalItems;

  /// The total number of pages available based on the items per page.
  final int totalPages;

  /// The current page number of the response.
  final int currentPage;

  /// The number of items included in each page of the response.
  final int itemsPerPage;
  
  @override
  List<Object?> get props => [
    items,
    totalItems,
    totalPages,
    currentPage,
    itemsPerPage,
  ];
}
