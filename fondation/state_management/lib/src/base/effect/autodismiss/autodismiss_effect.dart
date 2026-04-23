import 'package:state_management/src/bloc.dart';

/// Base class for auto-dismiss effects that are automatically dismissed after a short duration
abstract class AutoDismissEffect extends UiEffect {
  /// Duration after which the effect should be automatically dismissed
  Duration get autoDismissDuration;
}
