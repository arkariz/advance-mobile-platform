import 'package:equatable/equatable.dart';

final class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
  });

  factory User.empty() => const User(id: '', email: '', name: '');

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
      );

  final String id;
  final String email;
  final String name;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };

  @override
  List<Object?> get props => [id, email, name];

  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';
}
