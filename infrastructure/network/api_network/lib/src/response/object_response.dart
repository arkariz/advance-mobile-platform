import 'package:dependencies/dependencies.dart';

part 'object_response.g.dart';

/// A generic response model that can hold data of any type [T],
/// along with an optional status code and error information.
@JsonSerializable(genericArgumentFactories: true)
class ObjectResponse<T> {
  /// Creates an instance of [ObjectResponse] with the given parameters.
  ObjectResponse({
    this.statusCode,
    this.data,
  });

  /// Creates an instance of [ObjectResponse] from a JSON map, 
  /// using a provided function to parse the data of type [T].
  factory ObjectResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ObjectResponseFromJson(json, fromJsonT); 

  /// The HTTP status code of the response, if available.
  @JsonKey(name: 'code')
  final int? statusCode;

  /// The data payload of the response, which can be of any type [T].
  final T? data;
}
