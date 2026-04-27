import 'package:app_example/features/auth/domain/domain.dart';
import 'package:app_example/features/home/presentation/presentation.dart';
import 'package:dependencies/dependencies.dart';
import 'package:state_management/state_management.dart';

part 'home_event.dart';
part 'home_side_effect.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState.initial()) {
    on<HomeLogoutRequested>(_onLogoutRequested);
    on<HomeInitializeRequested>(_initalize);
  }

  void _initalize(
    HomeInitializeRequested event,
    Emitter<HomeState> emit,
  ) {
    // Simulate fetching user data and notifications count
    final user = User(id: '123', name: 'John Doe', email: 'john.doe@example.com');
    final notificationsCount = 5;

    emit(state.setUser(user).setNotificationsCount(notificationsCount));
  }

  void _onLogoutRequested(
    HomeLogoutRequested event,
    Emitter<HomeState> emit,
  ) {
    emit(state.withEffect(_effectLogout));
  }
}
