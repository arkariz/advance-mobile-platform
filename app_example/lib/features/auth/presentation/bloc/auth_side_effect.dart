part of 'auth_bloc.dart';

extension AuthSideEffect on AuthBloc {
  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════

  NavigatePushEffect get _effectNavigateToHome => NavigatePushEffect.withResult<String>(
    keyId: HomeRouteKeys.home.id,
    input: const HomeInput(),
    onResult: (result) {
      print('Navigated back from Home with result: $result');
    },
  );

  NavigateGoEffect get _effectNavigateToLogin => NavigateGoEffect(keyId: AuthRouteKeys.login.id, input: const EmptyInput());

  // ═══════════════════════════════════════════════════════════════════════════
  // SNACKBAR EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Generic authentication error snackbar
  ShowSnackBarEffect _effectAuthError(String message) => ShowSnackBarEffect(message: message, severity: FeedbackSeverity.error);

  /// Account created successfully snackbar
  // ignore: unused_element
  ShowSnackBarEffect get _effectAccountCreated => ShowSnackBarEffect(
    message: 'Account created successfully!',
    severity: FeedbackSeverity.success,
  );
}
