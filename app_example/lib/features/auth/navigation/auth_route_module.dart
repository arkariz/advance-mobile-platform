import 'package:app_example/features/auth/navigation/auth_route_keys.dart';
import 'package:app_example/features/auth/presentation/pages/login_page.dart';
import 'package:navigation/navigation.dart';

final class AuthRouteModule extends FeatureRouteModule {
  const AuthRouteModule();

  @override
  List<RouteNode> get routes => [
    RouteNode.typed<EmptyInput>(
      key: AuthRouteKeys.login,
      builder: (context, input) => const LoginPage(),
      transition: RouteTransition.fadeIn,
      defaultInput: EmptyInput.new,
    ),
  ];

  @override
  List<DevEntry> get devEntries => [
    DevEntry.typed<EmptyInput>(
      label: 'Login screen',
      category: 'Auth',
      key: AuthRouteKeys.login,
      inputFactory: EmptyInput.new,
    ),
  ];
}
