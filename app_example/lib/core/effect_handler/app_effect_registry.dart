import 'package:go_router/go_router.dart';
import 'package:state_management/state_management.dart';

import 'src/snackbar_effect_handler.dart';
import 'src/nav_effect_handler.dart';

/// Registers all effect handlers for the application into [globalEffectRegistry].
///
/// This is the single call-site for effect handler registration.
/// Called once at startup, before [runApp].
///
/// To add handlers for a new feature:
/// 1. Create `register<Feature>EffectHandlers(EffectRegistry)` in the feature folder.
/// 2. Call it here.
void registerEffectHandlers({required GoRouter router}) {
  registerNavEffectHandlers(globalEffectRegistry, router: router);
  registerSnackbarEffectHandlers(globalEffectRegistry);
}
