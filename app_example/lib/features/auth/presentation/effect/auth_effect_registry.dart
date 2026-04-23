import 'package:flutter/material.dart';
import 'package:state_management/state_management.dart';

/// Builds an [EffectRegistry] for auth screens.
///
/// [navigateRoutes] maps route names to page builders.
/// [NavigateGoEffect] will push-replace to the matching route.
EffectRegistry buildAuthEffectRegistry({
  Map<String, WidgetBuilder> navigateRoutes = const {},
}) {
  return EffectRegistry()
    ..register<ShowSnackBarEffect>((context, effect) {
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
    })
    ..register<NavigateGoEffect>((context, effect) {
      final builder = navigateRoutes[effect.route];
      if (builder != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: builder),
        );
      }
    });
}
