import 'package:mobile/core/usecase/usecase.dart';
import 'package:mobile/domain/auth/repository/auth.dart';
import 'package:mobile/service_locator.dart';

class IsLoggedInUseCase implements UseCase<bool,dynamic> {
  @override
  Future<bool> call({params}) async {
    return await sl<AuthRepository>().isLoggedIn();
  }

}
