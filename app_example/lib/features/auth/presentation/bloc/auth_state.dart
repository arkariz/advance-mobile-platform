import 'package:app_example/features/auth/domain/model/user.dart';
import 'package:state_management/state_management.dart';

sealed class AuthState extends UiState<AuthState> {
  const AuthState({super.effect});

  @override
  AuthState copyWith({UiEffect? effect}) => AuthInitial(effect: effect);
}

class AuthInitial extends AuthState {
  const AuthInitial({super.effect});

  @override
  List<Object?> get props => [];
}

class AuthLoading extends AuthState {
  const AuthLoading({this.message, super.effect});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user, {super.effect});
  
  final User user;

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({super.effect});

  @override
  List<Object?> get props => [];
}