import 'package:dependencies/dependencies.dart';

part 'user_response.g.dart';

@JsonSerializable()
class UserResponse {
  UserResponse({
    this.id,
    this.name,
    this.email,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => _$UserResponseFromJson(json);

  final String? id;
  final String? name;
  final String? email;
}