import 'package:navigation/navigation.dart';

final class HomeInput extends RouteInput {
  const HomeInput();
}

abstract final class HomeRouteKeys {
  static const home = RouteKey<HomeInput>('home.home');
}
