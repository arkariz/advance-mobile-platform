import 'package:api_network/src/response/response.dart';
import 'package:models/models.dart';

/// A class that implements the [PaginatedMapper] interface to map JSON data to a [Paginated] object using the [PaginatedResponse] model for parsing.
class PaginatedResponseMapper implements PaginatedMapper {
  @override
  Paginated<T> map<T>(Map<String, dynamic> json) {
    final paginatedResponse = PaginatedResponse.fromJson(json, (item) => item);
    return Paginated<T>(
      items: paginatedResponse.data?.map((e) => e as T).toList() ?? [],
      currentPage: paginatedResponse.pagination?.currentPage ?? 0,
      totalPages: paginatedResponse.pagination?.totalPages ?? 0,
      totalItems: paginatedResponse.pagination?.totalItems ?? 0,
      itemsPerPage: paginatedResponse.pagination?.itemsPerPage ?? 0,
    );
  }
}
