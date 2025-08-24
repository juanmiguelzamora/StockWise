import 'package:dartz/dartz.dart';
import 'package:mobile/core/usecase/usecase.dart';
import 'package:mobile/data/auth/models/user_creation_req.dart';
import 'package:mobile/domain/auth/repository/auth.dart';
import 'package:mobile/service_locator.dart';

class SignupUseCase implements UseCase<Either,UserCreationReq> {


  @override
  Future<Either> call({UserCreationReq ? params}) async {
    return await sl<AuthRepository>().signup(params!);
  }

  
}
