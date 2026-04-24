part of 'home_bloc.dart';

sealed class HomeState extends UiState<HomeState> {
  const HomeState({super.effect});
}

final class HomeIdle extends HomeState {
  const HomeIdle({super.effect});

  @override
  HomeState copyWith({UiEffect? effect}) => HomeIdle(effect: effect);

  @override
  List<Object?> get props => [];
}
