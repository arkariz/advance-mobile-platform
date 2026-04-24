import 'package:navigation/src/dev/dev_entry.dart';
import 'package:navigation/src/feature_route_module.dart';
import 'package:navigation/src/route_input.dart';
import 'package:navigation/src/route_key.dart';
import 'package:navigation/src/route_node.dart';

/// Immutable registry of all [RouteNode]s in the application.
///
/// Built once at app startup from a list of [FeatureRouteModule]s. After
/// construction the registry is sealed — no further mutations are possible.
///
/// ## Duplicate key detection
/// In debug builds, [RouteRegistry.fromModules] asserts that all [RouteKey]
/// identifiers are globally unique. A collision is always a programming error.
///
/// ## Usage
/// ```dart
/// final registry = RouteRegistry.fromModules([
///   AuthRouteModule(),
///   ProfileRouteModule(),
/// ]);
/// ```
final class RouteRegistry {
  RouteRegistry._({
    required Map<String, RouteNode> nodes,
    required List<DevEntry> devEntries,
  })  : _nodes = Map.unmodifiable(nodes),
        _devEntries = List.unmodifiable(devEntries);

  /// Builds a [RouteRegistry] from a list of [FeatureRouteModule]s.
  ///
  /// Asserts uniqueness of all [RouteKey] identifiers. Throws [StateError]
  /// in debug mode if duplicates are found.
  factory RouteRegistry.fromModules(List<FeatureRouteModule> modules) {
    final nodes = <String, RouteNode>{};
    final devEntries = <DevEntry>[];

    for (final module in modules) {
      for (final node in module.routes) {
        assert(
          !nodes.containsKey(node.keyId),
          'Duplicate route key detected: "${node.keyId}". '
          'Each RouteKey must be globally unique across all FeatureRouteModules.',
        );
        nodes[node.keyId] = node;
      }
      devEntries.addAll(module.devEntries);
    }

    return RouteRegistry._(nodes: nodes, devEntries: devEntries);
  }

  final Map<String, RouteNode> _nodes;
  final List<DevEntry> _devEntries;

  /// Resolves the [RouteNode] for the given typed [key].
  ///
  /// Returns `null` if no node is registered for [key].
  RouteNode? resolve<TInput extends RouteInput>(RouteKey<TInput> key) =>
      _nodes[key.id];

  /// Resolves the [RouteNode] for a raw string key identifier.
  ///
  /// Used internally by effect handlers where the key's generic type has
  /// been erased. Prefer [resolve] at typed call sites.
  RouteNode? resolveById(String keyId) => _nodes[keyId];

  /// All registered [DevEntry]s, collected from every [FeatureRouteModule].
  List<DevEntry> get devEntries => _devEntries;

  /// All registered route key IDs. Useful for debugging and logging.
  Iterable<String> get registeredKeys => _nodes.keys;

  /// All registered [RouteNode]s. Used to build the router at app startup.
  Iterable<RouteNode> get registeredNodes => _nodes.values;
}
