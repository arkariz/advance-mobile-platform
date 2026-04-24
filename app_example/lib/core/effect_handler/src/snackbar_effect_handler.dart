import 'package:flutter/material.dart';
import 'package:state_management/state_management.dart';

/// Registers auth-feature effect handlers into the given [registry].
///
/// Handles UI-local effects (snackbars, dialogs). Navigation effects are
/// handled globally by [registerNavEffectHandlers] and do not need to be
/// registered here.
void registerSnackbarEffectHandlers(EffectRegistry registry) {
  registry.register<ShowSnackBarEffect>((context, effect) {
    final color = switch (effect.severity) {
      FeedbackSeverity.success => Colors.green,
      FeedbackSeverity.warning => Colors.orange,
      FeedbackSeverity.error => Colors.red,
      FeedbackSeverity.info => Colors.blue,
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(effect.message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  });
}
