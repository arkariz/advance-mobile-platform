import 'package:dependencies/dependencies.dart';

part 'paginated_response.g.dart';

/// A generic response model for paginated data, containing a list of items of type [T],
/// pagination details, and optional status code and error information.
@JsonSerializable(genericArgumentFactories: true, createToJson: true)
class PaginatedResponse<T> {
  /// Creates an instance of [PaginatedResponse] with the given parameters.
  PaginatedResponse({
    this.statusCode,
    this.data,
    this.pagination,
  });

  /// Creates an instance of [PaginatedResponse] from a JSON map,
  /// using a provided function to parse the data of type [T].
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);

  /// Converts the [PaginatedResponse] instance to a JSON map, using a provided function to serialize the data of type [T].
  Map<String, dynamic> toJson() => _$PaginatedResponseToJson(this, (value) => value);


  /// The HTTP status code of the response, if available.
  @JsonKey(name: 'code')
  final int? statusCode;

  /// The list of data items of type [T] contained in the response.
  final List<T>? data;

  /// The pagination details of the response, if available.
  final PaginationResponse? pagination;
}

/// A model representing pagination details, including total items, total pages,
/// current page, and items per page.
@JsonSerializable(createToJson: true)
class PaginationResponse {
  /// Creates an instance of [PaginationResponse] with the given parameters.
  PaginationResponse({
    this.totalItems,
    this.totalPages,
    this.currentPage,
    this.itemsPerPage,
  });

  /// Creates an instance of [PaginationResponse] from a JSON map.
  factory PaginationResponse.fromJson(Map<String, dynamic> json) => _$PaginationResponseFromJson(json);

  /// Converts the [PaginationResponse] instance to a JSON map.
  Map<String, dynamic> toJson() => _$PaginationResponseToJson(this);

  /// The total number of items available across all pages.
  final int? totalItems;

  /// The total number of pages available based on the items per page.
  final int? totalPages;

  /// The current page number of the response.
  final int? currentPage;

  /// The number of items included in each page of the response.
  final int? itemsPerPage;
}
