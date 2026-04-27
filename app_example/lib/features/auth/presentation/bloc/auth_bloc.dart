import 'dart:async';

import 'package:app_example/features/auth/domain/domain.dart';
import 'package:app_example/features/auth/presentation/presentation.dart';
import 'package:app_example/features/home/presentation/presentation.dart';
import 'package:failures/failures.dart';
import 'package:navigation/navigation.dart';
import 'package:state_management/state_management.dart';

part 'auth_side_effect.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository}) 
  :  _authRepository = authRepository,
    super(const AuthInitial()) {
      on<AuthSignInWithEmailRequested>(_onSignInWithEmailRequested);
      on<AuthSignOutRequested>(_onSignOutRequested);
    }

  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;


  Future<void> _onSignInWithEmailRequested(
    AuthSignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing in...'));

    try {
      final result = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(result, effect: _effectNavigateToHome));
    } on Failure catch (failure) {
      emit(AuthUnauthenticated(effect: _effectAuthError(failure.message)));
    }
  }


  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing out...'));

    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated(effect: _effectNavigateToLogin));
    } on Failure catch (failure) {
      if (state is AuthAuthenticated) {
        emit(state.withEffect(_effectAuthError(failure.message)));
      } else {
        emit(AuthUnauthenticated(effect: _effectAuthError(failure.message)));
      }
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
