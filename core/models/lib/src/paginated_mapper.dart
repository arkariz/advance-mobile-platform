import 'package:models/src/paginated.dart';

/// An abstract class defining the contract for mapping JSON data to a [Paginated] object.
// ignore: one_member_abstracts
abstract class PaginatedMapper {
  /// Maps a JSON object to a [Paginated] instance containing items of type [T].
  /// The JSON structure is expected to contain pagination metadata (totalItems, totalPages, currentPage, itemsPerPage) and a list of items under a specific key (e.g., 'data' or 'items').
  /// The implementation of this method should handle the parsing of the JSON and the mapping of the items to the appropriate type [T].
  Paginated<T> map<T>(Map<String, dynamic> json);
}
