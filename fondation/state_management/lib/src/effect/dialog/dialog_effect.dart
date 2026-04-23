//
// ignore_for_file: public_member_api_docs

import 'package:state_management/src/bloc.dart';

/// Show dialog with intent-based actions (no callbacks)
final class ShowDialogEffect extends UiEffect implements InteractiveEffect {
  /// Creates a [ShowDialogEffect] with the given parameters.
  ShowDialogEffect({
    required this.intentId,
    required this.title,
    required this.message,
    required this.actions,
    this.isDismissible = true,
    this.isFullScreen = false,
    this.icon,
  });

  factory ShowDialogEffect.fullScreen({
    required String intentId,
    required String title,
    required String message,
    required List<DialogActionConfig> actions,
  }) {
    return ShowDialogEffect(
      intentId: intentId,
      title: title,
      message: message,
      actions: actions,
      isDismissible: false,
      isFullScreen: true,
    );
  }

  factory ShowDialogEffect.simple({
    required String intentId,
    required String title,
    required String message,
    required List<DialogActionConfig> actions,
    DialogIcon? icon,
    bool isDismissible = true,
  }) {
    return ShowDialogEffect(
      intentId: intentId,
      title: title,
      message: message,
      actions: actions,
      isDismissible: isDismissible,
      icon: icon,
    );
  }

  @override
  final String intentId;
  final String title;
  final String message;
  final List<DialogActionConfig> actions;
  final bool isDismissible;
  final bool isFullScreen;
  final DialogIcon? icon;

  @override
  List<Object?> get props => [
    ...super.props, // Include timestamp from UiEffect
    intentId,
    title,
    message,
    actions.map((a) => a.action).toList(),
    isDismissible,
    isFullScreen,
    icon,
  ];
}
