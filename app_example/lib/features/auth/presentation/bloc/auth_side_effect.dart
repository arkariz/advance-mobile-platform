part of 'auth_bloc.dart';

extension AuthSideEffect on AuthBloc {
  // ═══════════════════════════════════════════════════════════════════════════
  // NAVIGATION EFFECTS
  // ═══════════════════════════════════════════════════════════════════════════

  NavigateGoEffect get _effectNavigateToHome => NavigateGoEffect(route: "home");
  NavigateGoEffect get _effectNavigateToLogin => NavigateGoEffect(route: "login");

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
