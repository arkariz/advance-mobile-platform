import 'package:state_management/src/bloc.dart';

/// Feedback severity levels for snackbars
// ignore: public_member_api_docs
enum FeedbackSeverity { info, success, warning, error }

/// Effect to show a snackbar with a message, severity, and optional action
final class ShowSnackBarEffect extends AutoDismissEffect {
  /// Creates a [ShowSnackBarEffect] with the given parameters.
  ShowSnackBarEffect({
    required this.message,
    this.severity = FeedbackSeverity.info,
    this.actionLabel,
    this.actionIntentId,
    this.autoDismissDuration = const Duration(seconds: 4),
  }) : assert(
    actionLabel == null || actionIntentId != null,
    'actionIntentId required when actionLabel provided',
  );
  
  /// The message to display in the snackbar
  final String message;
  /// The severity level of the feedback (e.g., info, success, warning, error)
  final FeedbackSeverity severity;
  /// Optional label for the snackbar action button
  final String? actionLabel;
  /// Optional intent ID to trigger when the action button is pressed
  final String? actionIntentId;

  @override
  final Duration autoDismissDuration;


  @override
  List<Object?> get props => [
    ...super.props, // Include timestamp from UiEffect
    message,
    severity,
    actionLabel,
    actionIntentId,
    autoDismissDuration,
  ];
}
