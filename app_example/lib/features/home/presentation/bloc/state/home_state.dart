import 'package:app_example/features/auth/domain/domain.dart';
import 'package:state_management/state_management.dart';

final class HomeState extends UiState<HomeState> {
  const HomeState({
    super.effect,
    required this.user,
    required this.notificationsCount,
  });
  
  final User user;
  final int notificationsCount;

  factory HomeState.initial() => HomeState(
    user: User.empty(),
    notificationsCount: 0,
  );

  // ==== Setter ====
  HomeState setUser(User user) => copyWith(user: user);
  HomeState setNotificationsCount(int count) => copyWith(notificationsCount: count);

  @override
  HomeState copyWith({
    User? user,
    int? notificationsCount,
    UiEffect? effect,
  }) => HomeState(
    user: user ?? this.user,
    notificationsCount: notificationsCount ?? this.notificationsCount,
    effect: effect,
  );

  @override
  List<Object?> get props => [user, notificationsCount];
}
