import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:state_management/state_management.dart';

/// Registers handlers for all [NavigationEffect] subtypes in the given
/// [registry], delegating to [router] for actual navigation.
///
/// Call this once at app startup, before [runApp]:
/// ```dart
/// registerNavEffectHandlers(
///   registry: globalEffectRegistry,
///   router: _router,
/// );
/// ```
///
/// After registration, any BLoC that emits a [NavigateGoEffect],
/// [NavigatePushEffect], [NavigateReplaceEffect], or [NavigatePopEffect]
/// will be handled globally — no per-page [EffectRegistry] wiring needed.
void registerNavEffectHandlers(
  EffectRegistry registry,
  {required GoRouter router}
) {
  registry
    ..register<NavigateGoEffect>((context, effect) {
      router.go('/${effect.keyId}', extra: effect.input);
    })
    ..register<NavigatePushEffect>((context, effect) {
      router
          .push<Object?>('/${effect.keyId}', extra: effect.input)
          .then((result) => effect.onResult?.call(result))
          .onError((error, stackTrace) {
            FlutterError.reportError(
              FlutterErrorDetails(
                exception: error ?? 'Unknown error during NavigatePushEffect',
                stack: stackTrace,
                library: 'nav_effect_handler',
                context: ErrorDescription(
                    'while handling NavigatePushEffect for "${effect.keyId}"'),
              ),
            );
      }); 
    })
    ..register<NavigateReplaceEffect>((context, effect) {
      router.replace('/${effect.keyId}', extra: effect.input);
    })
    ..register<NavigatePopEffect>((context, effect) {
      router.pop(effect.result);
    });
}
