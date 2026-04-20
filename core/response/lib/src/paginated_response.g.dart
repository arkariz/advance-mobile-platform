// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paginated_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PaginatedResponse<T>(
  statusCode: (json['code'] as num?)?.toInt(),
  data: (json['data'] as List<dynamic>?)?.map(fromJsonT).toList(),
  pagination: json['pagination'] == null
      ? null
      : PaginationResponse.fromJson(json['pagination'] as Map<String, dynamic>),
);

PaginationResponse _$PaginationResponseFromJson(Map<String, dynamic> json) =>
    PaginationResponse(
      totalItems: (json['total_items'] as num?)?.toInt(),
      totalPages: (json['total_pages'] as num?)?.toInt(),
      currentPage: (json['current_page'] as num?)?.toInt(),
      itemsPerPage: (json['items_per_page'] as num?)?.toInt(),
    );
