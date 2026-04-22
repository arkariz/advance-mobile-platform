// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:api_network/api_network.dart' as _i976;
import 'package:dio_network/dio_network.dart' as _i347;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../analytics/analytics_service.dart' as _i726;
import 'root_module.dart' as _i126;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> $initAppGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final rootModule = _$RootModule();
    await gh.singletonAsync<bool>(
      () => rootModule.sharedPreferences(),
      preResolve: true,
    );
    gh.lazySingleton<_i347.Dio>(() => rootModule.dio());
    gh.lazySingleton<_i976.NetworkCallHandler>(
      () => rootModule.authNetworkCallHandler(),
    );
    gh.lazySingleton<_i726.AnalyticsService>(
      () => rootModule.analyticsService(),
    );
    return this;
  }
}

class _$RootModule extends _i126.RootModule {}
