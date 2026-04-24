import 'package:navigation/src/dev/dev_entry.dart';
import 'package:navigation/src/route_node.dart';

/// Contract between a feature module and the app-level [RouteRegistry].
///
/// Each feature that participates in the navigation framework implements this
/// class and declares its [routes]. The app layer collects all modules and
/// passes them to [RouteRegistry.fromModules].
///
/// Scope lifecycle is intentionally NOT managed here — that responsibility
/// belongs to the caller (the app/dashboard layer or a coordinator widget).
///
/// ## Example
/// ```dart
/// final class AuthRouteModule extends FeatureRouteModule {
///   @override
///   List<RouteNode> get routes => [
///     RouteNode.typed<LoginInput>(
///       key: AuthRouteKeys.login,
///       builder: (ctx, input) => LoginPage(input: input),
///     ),
///   ];
///
///   @override
///   List<DevEntry> get devEntries => [
///     DevEntry.typed<LoginInput>(
///       label: 'Login screen',
///       category: 'Auth',
///       key: AuthRouteKeys.login,
///       inputFactory: LoginInput.new,
///     ),
///   ];
/// }
/// ```
abstract class FeatureRouteModule {
  /// Const constructor since this class is immutable and has no fields.
  const FeatureRouteModule();

  /// All [RouteNode]s owned by this feature module.
  List<RouteNode> get routes;

  /// Optional [DevEntry] list for the debug launcher.
  ///
  /// Override in feature modules to expose quick-launch entries for dev/QA.
  /// These are only shown in debug builds.
  List<DevEntry> get devEntries => const [];
}
