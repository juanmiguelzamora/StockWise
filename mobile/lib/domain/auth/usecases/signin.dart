import 'package:dartz/dartz.dart';
import 'package:mobile/core/usecase/usecase.dart';
import 'package:mobile/data/auth/models/user_signin_req.dart';
import 'package:mobile/domain/auth/repository/auth.dart';
import 'package:mobile/service_locator.dart';

class SigninUseCase implements UseCase<Either,UserSigninReq> {
  
  @override
  Future<Either> call({UserSigninReq ? params}) async {
    return sl<AuthRepository>().signin(params!);
  }
  
}

