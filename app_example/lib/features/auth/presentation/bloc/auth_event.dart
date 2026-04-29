import 'package:dependencies/dependencies.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched once when the auth feature initialises.
///
/// The Bloc will read secure storage to determine whether a session already
/// exists and emit [AuthAuthenticated] or [AuthUnauthenticated] accordingly.
class AuthStarted extends AuthEvent {
  const AuthStarted();
}

/// Sign in with email and password
class AuthSignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInWithEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
