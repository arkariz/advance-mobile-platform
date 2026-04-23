import 'package:state_management/src/bloc.dart';

/// Base class for interactive effects that require user response
abstract class InteractiveEffect extends UiEffect {
  /// Unique intent ID to identify the user response for this effect
  String get intentId;
}
