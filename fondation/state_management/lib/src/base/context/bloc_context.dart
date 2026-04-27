import 'package:dependencies/dependencies.dart';

/// Base class for BLoC-internal contextual data.
///
/// [BlocContext] holds data that:
/// - Is needed for internal logic or to be passed to outer layers (repository, use case, effect)
/// - Does NOT trigger UI rebuilds — it is never emitted to the state stream
/// - Persists across multiple events within the same BLoC lifecycle
///
/// Use [UiState] when the data needs to be rendered on the UI.
/// Use [BlocContext] when the data is invisible to the UI but drives logic.
///
/// Example:
/// ```dart
/// class AuthContext extends BlocContext<AuthContext> {
///   const AuthContext({this.pendingEmail = '', this.retryCount = 0});
///
///   final String pendingEmail;
///   final int retryCount;
///
///   @override
///   AuthContext copyWith({String? pendingEmail, int? retryCount}) => AuthContext(
///     pendingEmail: pendingEmail ?? this.pendingEmail,
///     retryCount: retryCount ?? this.retryCount,
///   );
/// }
/// ```
abstract class BlocContext<T extends BlocContext<T>> extends Equatable {
  /// Creates a [BlocContext]. Subclasses should provide their own fields and override [copyWith].
  const BlocContext();

  /// Returns a copy of this context with the provided fields replaced.
  T copyWith();

  @override
  bool? get stringify => true;
}
