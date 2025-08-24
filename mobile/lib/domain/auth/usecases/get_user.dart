import 'package:dartz/dartz.dart';
import 'package:mobile/core/usecase/usecase.dart';
import 'package:mobile/domain/auth/repository/auth.dart';
import 'package:mobile/service_locator.dart';

class GetUserUseCase implements UseCase<Either,dynamic> {
  @override
  Future<Either> call({params}) async {
    return await sl<AuthRepository>().getUser();
  }

}
