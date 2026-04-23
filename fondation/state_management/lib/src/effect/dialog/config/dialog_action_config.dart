import 'dart:ui';

/// Dialog action types and configuration
// ignore: public_member_api_docs
enum DialogAction { confirm, cancel, destructive, neutral }

/// Dialog icons for visual emphasis
// ignore: public_member_api_docs
enum DialogIcon { info, success, warning, error, question }

/// Dialog action button configuration
///
/// [onPressed] is optional - if null, dialog will just pop with the [action] value.
/// If provided, it will be called AND dialog will still pop.
class DialogActionConfig {
  /// Creates a [DialogActionConfig] with the given parameters.
  const DialogActionConfig({
    required this.action,
    this.label,
    this.isPrimary = false,
    this.onPressed,
  });

  /// The type of action (e.g., confirm, cancel).
  final DialogAction action;
  
  /// Optional custom label for the action button. Defaults to standard labels based on [action].
  final String? label;
  
  /// Whether this action is the primary action (e.g., styled differently).
  final bool isPrimary;
  
  /// Optional callback when this action is pressed.
  /// Called before Navigator.pop().
  /// Note: Excluded from equality comparison.
  final VoidCallback? onPressed;

  /// Default labels based on action type
  String get defaultLabel => switch (action) {
    DialogAction.confirm => 'OK',
    DialogAction.cancel => 'Cancel',
    DialogAction.destructive => 'Delete',
    DialogAction.neutral => 'Skip',
  };

  /// Effective label to display on the button, using custom label if provided, otherwise default.
  String get effectiveLabel => label ?? defaultLabel;
}
