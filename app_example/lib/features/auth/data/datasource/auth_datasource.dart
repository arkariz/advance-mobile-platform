import 'package:app_example/features/auth/data/data.dart';
import 'package:dependencies/dependencies.dart';
import 'package:api_network/api_network.dart';

part 'auth_datasource.g.dart';

@RestApi()
abstract class AuthDatasource {
  factory AuthDatasource(Dio dio, {String? baseUrl}) = _AuthDatasource;

  @POST('/sign_in')
  Future<ObjectResponse<UserResponse>> signIn({
    @Query('email') required String email,
    @Query('password') required String password,
  });

  @POST('/sign_out')
  Future<ObjectResponse<void>> signOut();
}