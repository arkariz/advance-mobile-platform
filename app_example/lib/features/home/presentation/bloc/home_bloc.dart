import 'package:dependencies/dependencies.dart';
import 'package:state_management/state_management.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_side_effect.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeIdle()) {
    on<HomeLogoutRequested>(_onLogoutRequested);
  }

  void _onLogoutRequested(
    HomeLogoutRequested event,
    Emitter<HomeState> emit,
  ) {
    emit(state.withEffect(_effectLogout));
  }
}
