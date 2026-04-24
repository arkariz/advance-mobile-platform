/// Defines the page transition animation used when navigating to a route.
enum RouteTransition {
  /// Standard platform-adaptive transition (default).
  material,

  /// Cross-fade transition.
  fadeIn,

  /// Slide in from the right (standard push direction).
  slideFromRight,

  /// Slide in from the bottom (modal-style).
  slideFromBottom,

  /// No transition animation.
  none,
}
