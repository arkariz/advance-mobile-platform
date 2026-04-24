import 'package:navigation/src/route_input.dart';
import 'package:navigation/src/route_key.dart';

/// Represents a quick-launch entry for a screen in the [DevMenuScreen].
///
/// Each entry declares a human-readable [label], a [category] (typically the
/// feature name) for grouping in the menu, and a factory that produces a
/// default [RouteInput] so the screen can be opened without needing to
/// navigate through the normal flow.
///
/// [DevEntry] is deliberately not generic at the class level. Type safety is
/// enforced at construction time via [DevEntry.typed]. Internally the input
/// factory is stored with a type-erased signature.
///
/// ## Example
/// ```dart
/// DevEntry.typed<ProfileInput>(
///   label: 'Profile — loaded state',
///   category: 'Profile',
///   key: ProfileRouteKeys.view,
///   inputFactory: () => ProfileInput(userId: 'dev-user-1'),
/// )
/// ```
final class DevEntry {
  DevEntry._internal({
    required this.label,
    required this.category,
    required this.keyId,
    required RouteInput Function() inputFactory,
  }) : _inputFactory = inputFactory;

  /// Creates a [DevEntry] with compile-time input type validation.
  static DevEntry typed<TInput extends RouteInput>({
    required String label,
    required String category,
    required RouteKey<TInput> key,
    required TInput Function() inputFactory,
  }) =>
      DevEntry._internal(
        label: label,
        category: category,
        keyId: key.id,
        inputFactory: inputFactory,
      );

  /// Human-readable label shown in the [DevMenuScreen].
  final String label;

  /// Feature-level grouping label (e.g., `'Auth'`, `'Profile'`).
  final String category;

  /// The string identifier of the target [RouteKey].
  final String keyId;

  final RouteInput Function() _inputFactory;

  /// Produces a fresh [RouteInput] instance for this entry.
  ///
  /// Called each time the entry is launched, allowing stateful inputs to
  /// be reset on each invocation.
  RouteInput createInput() => _inputFactory();
}
