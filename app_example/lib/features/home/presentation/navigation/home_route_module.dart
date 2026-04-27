import 'package:app_example/features/home/presentation/navigation/home_route_keys.dart';
import 'package:app_example/features/home/presentation/bloc/home_bloc.dart';
import 'package:app_example/features/home/presentation/pages/home_page.dart';
import 'package:navigation/navigation.dart';
import 'package:state_management/state_management.dart';


final class HomeRouteModule extends FeatureRouteModule {
  const HomeRouteModule();

  @override
  List<RouteNode> get routes => [
    RouteNode.typed<HomeInput>(
      key: HomeRouteKeys.home,
      builder: (context, input) => BlocProvider(
        create: (_) => HomeBloc(),
        child: const HomePage(),
      ),
      transition: RouteTransition.fadeIn,
    ),
  ];

  @override
  List<DevEntry> get devEntries => [
    DevEntry.typed<HomeInput>(
      label: 'Home screen',
      category: 'Home',
      key: HomeRouteKeys.home,
      inputFactory: HomeInput.new,
    ),
  ];
}
