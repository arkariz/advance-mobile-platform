part of 'home_bloc.dart';

extension HomeSideEffect on HomeBloc {
  NavigatePopEffect get _effectLogout => NavigatePopEffect(result: 'logged_out');
}
