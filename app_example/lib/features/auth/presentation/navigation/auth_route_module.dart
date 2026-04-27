import 'package:app_example/features/auth/presentation/presentation.dart';
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
