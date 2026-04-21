// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'object_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ObjectResponse<T> _$ObjectResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ObjectResponse<T>(
  statusCode: (json['code'] as num?)?.toInt(),
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
);

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);
