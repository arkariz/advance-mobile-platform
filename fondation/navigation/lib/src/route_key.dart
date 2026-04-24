import 'package:flutter/foundation.dart';
import 'package:navigation/src/route_input.dart';

/// A typed token that uniquely identifies a route within the application.
///
/// The generic parameter [TInput] binds the key to a specific [RouteInput]
/// type, enabling compile-time validation when navigating. The key is backed
/// by a namespaced string identifier (e.g. `'auth.login'`).
///
/// Declare keys as constants in a feature-level constants class:
/// ```dart
/// abstract final class AuthRouteKeys {
///   static const login = RouteKey<LoginInput>('auth.login');
///   static const home  = RouteKey<HomeInput>('auth.home');
/// }
/// ```
///
/// The `TInput` binding is enforced at the [AppNavService.push] call site and
/// at [RouteNode] registration time, preventing input type mismatches.
@immutable
final class RouteKey<TInput extends RouteInput> {
  /// Creates a [RouteKey] with the given string identifier.
  const RouteKey(this.id);

  /// Namespaced string identifier. Must be globally unique across the app.
  ///
  /// Convention: `'<feature>.<screen>'`, e.g. `'auth.login'`, `'profile.view'`.
  final String id;
  
  @override
  bool operator ==(Object other) => identical(this, other) || (other is RouteKey && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'RouteKey<$TInput>($id)';
}
