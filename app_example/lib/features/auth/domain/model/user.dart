import 'package:equatable/equatable.dart';

final class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.name,
  });

  final String id;
  final String email;
  final String name;

  factory User.empty() => const User(id: '', email: '', name: '');

  @override
  List<Object?> get props => [id, email, name];

  @override
  String toString() => 'User(id: $id, email: $email, name: $name)';
}
