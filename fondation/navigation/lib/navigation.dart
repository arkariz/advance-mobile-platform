/// Modular, type-safe navigation framework for Flutter.
///
/// ## Core abstractions
/// - [RouteInput] — marker base class for screen input types
/// - [RouteKey] — typed token identifying a route (`'feature.screen'`)
/// - [RouteNode] — descriptor combining key + builder + transition
/// - [RouteRegistry] — immutable map of all registered [RouteNode]s
/// - [FeatureRouteModule] — feature-level route declaration contract
///
/// ## Typed navigation effects
/// Live in `package:state_management`, not here, to keep navigation
/// decoupled from BLoC/state_management concerns:
/// - [TypedNavigateGoEffect] — replace current route
/// - [TypedNavigatePushEffect] — push with optional result callback
/// - [TypedNavigateReplaceEffect] — push-replace current route
/// - [TypedNavigatePopEffect] — pop with optional result
///
/// ## Dev tooling
/// - [DevEntry] — quick-launch descriptor for a screen with mock input
/// - [DevMenuScreen] — debug UI listing all registered [DevEntry]s
library ;

export 'src/dev/dev_entry.dart';
export 'src/dev/dev_menu_screen.dart';
export 'src/feature_route_module.dart';
export 'src/route_input.dart';
export 'src/route_key.dart';
export 'src/route_node.dart';
export 'src/route_registry.dart';
export 'src/route_transition.dart';
