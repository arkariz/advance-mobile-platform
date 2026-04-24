/// Marker base class for all strongly-typed screen inputs.
///
/// Every screen that participates in the navigation framework must declare
/// its own [RouteInput] subclass. This makes screen contracts explicit and
/// enables compile-time validation at navigation call sites.
///
/// Example:
/// ```dart
/// final class LoginInput extends RouteInput {
///   const LoginInput();
/// }
///
/// final class ProfileInput extends RouteInput {
///   const ProfileInput({required this.userId});
///   final String userId;
/// }
/// ```
abstract class RouteInput {
  /// Base constructor for [RouteInput]. Subclasses can add parameters as needed.
  const RouteInput();
}

/// A [RouteInput] for screens that require no parameters.
///
/// Use when a screen has no meaningful input but the framework still
/// requires a [RouteInput] type.
final class EmptyInput extends RouteInput {
  /// Const constructor since there are no fields.
  const EmptyInput();
}
